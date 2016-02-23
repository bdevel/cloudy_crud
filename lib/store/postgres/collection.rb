
# http://ruby-journal.com/how-to-import-millions-records-via-activerecord-within-minutes-not-hours/
# TODO: Unify type and collection as they should always be the same.

module CloudyCrud::Store
  class Postgres
    class Collection
      @@existing_collections_cache = []
      
      attr_reader :domain, :collection
      def initialize(domain, collection)
        @domain     = CloudyCrud::Store::Postgres.clean_identifier(domain)
        @collection = CloudyCrud::Store::Postgres.clean_identifier(collection)
      end

      def save(record)
        # create scheme and table if doesn't exist.
        create_table!() unless table_exists?
        
        if record._id
          db[sequel_table_accessor]
            .where(:id => record._id) # TODO: permissions?
            .update(
              updated_at: Sequel.lit('NOW()'),
              data: record.to_json
            )
        else
          new_id = db[sequel_table_accessor]
                   .where(:id => record._id)
                   .insert(
                     domain:     @domain,
                     collection: @collection,
                     data:       record.to_json,
                     updated_at: Sequel.lit('NOW()'),
                     created_at: Sequel.lit('NOW()')
                   )
          
          record._id = new_id
        end
        record
      end

      # def find(query)
      #   player_ids = Sequel.pg_array_op(:data)
      #   # Is admin or is reader
      #   # data #> '{permissions,admin,users}' ? 'tyler' -- does that array include tyler?
      #   # data #> '{permissions,admin,groups}' ?| array['public', '453']; -- does groups include any of our array items?
      #   # data #> '{permissions,read,users}' ? 'tyler' -- does that array include tyler?
      #   # data #> '{permissions,read,groups}' ?| array['public', '453']; -- does groups include any of our array items?
      #   sql = %~ SET constraint_exclusion = partition; -- Make query go to the right partition
      #       SELECT * FROM "cloudy_crud"."records"
      #       WHERE
      #         "domain"     = $1::text    AND
      #         "collection" = $2::text    AND
      #         "data"       @> $3::jsonb;
      # ~
      #   self.with_connection do |conn|
      #     result = conn.exec_params(
      #       sql,
      #       [
      #         query.domain,
      #         query.collection,
      #         JSON.dump({id: query.id})
      #       ]
      #     )
      #   end
      # end
      
      @@existing_collections = []
      def table_exists?
        # check out cache first
        if @@existing_collections_cache.include?(sequel_table_accessor)
          return true
        end

        # Query db to see if that table exists
        does_exist = db[:pg_class]
          .join(:pg_namespace, :oid => :relnamespace)
          .where(
            :relkind => 'r',
            :relname => table_name.to_s,
            :nspname => schema_name.to_s
          )
          .count > 0
        
        @@existing_collections_cache << sequel_table_accessor if does_exist
        return does_exist
      end

      def sequel_table_accessor
        "#{schema_name}__#{table_name}".to_sym
      end
      
      def table_name
        "#{@collection}"
      end
      
      def schema_name
        "#{CloudyCrud::Store::Postgres::SCHEMA_PREFIX}#{@domain}"
      end
      
      def create_table!()
        table_opts = {inherits: :'cloudy_crud__records'}
        check_opts = {:domain => "#{@domain}", :collection => table_name}
        
        db.create_schema(schema_name, :if_not_exists => true)
        db.create_table(sequel_table_accessor, table_opts) do
          check(*check_opts)
        end

        # Create an index for the permissions
        {
          # admin
          admin_users: "GIN ((data #> '{permissions,admin,users}')::text[])",
          admin_groups: "GIN ((data #> '{permissions,admin,groups}'::text[]))",

          # read
          read_users: "GIN ((data #> '{permissions,read,users}'::text[]))",
          read_groups: "GIN ((data #> '{permissions,read,groups}'::text[]))",

          # write
          write_users: "GIN ((data #> '{permissions,write,users}'::text[]))",
          write_groups: "GIN ((data #> '{permissions,write,groups}'::text[]))"
        }.each do |name, using|
          idx_name =  "#{sequel_table_accessor}_permissions_#{name}_index"
          db.add_index(sequel_table_accessor, [:data], :name => idx_name, :using => using)
        end

        @@existing_collections_cache << sequel_table_accessor # cache that we just created it
        true
      end

      private

      # shortcut helper
      def db
        CloudyCrud::Store::Postgres.db
      end
      
    end # Collection
  end # Postgres
end# Store
