require 'sequel'
Sequel.extension(:pg_json_ops)

require_relative './postgres/collection'

module CloudyCrud::Store
  class Postgres
    SCHEMA_PREFIX='cc_'
    include CustomizableClassMethod
    
    #customizable_class_method :connection_ do
    #  raise CloudyCrud::Error.new("CloudyCrud::Store::Postgres connection has not been configured.")
    #end

    @@connection_config
    def self.connection_config; @@connection_config; end
    def self.connection_config=(v)
      @@connection_config = v
    end
    
    @@db
    def self.db
      @@db ||= Sequel.connect(@@connection_config)
    end
    
    def self.setup_schema
      # Make our base schema which all others inherit from.
      self.db.create_schema("cloudy_crud", :if_not_exists => true)
      self.db.create_table(:"cloudy_crud__records", :if_not_exists => true) do
        primary_key :id,    "BIGSERIAL"
        column :domain,     String
        column :collection, String
        column :created_at, DateTime
        column :updated_at, DateTime
        column :data,       "JSONB"
      end
    end

    # Not a santizier, sequel will do most of that
    def self.clean_identifier(ident)
      ident.gsub(/^pg_/, 'xpg_') # don't create any pg_ schemas or tables
        .gsub(/_+/, '') # remove mulitple underscores as Sequel uses that to seperate schemas
        .gsub("'", '') # remove single quotes
        .gsub('"', '') # remove double quotes
    end
    
    
    def self.save(record)
      collection = Collection.new(record.domain, record.collection)
      collection.save(record)
    end

    def self.destroy(record, requesting_user=nil)
      # make sure is admin to delete
      # data #> '{permissions,admin,users}' ? 'tyler' OR data data #> '{permissions,admin,groups}' ?| array['public', '453']
      if record._id
      else
        raise CloudyCrud::Error.new("Cannot destroy a record that has not been saved.")
      end
    end
    
    def self.find(query)
    end
    
    
    # def self.execute(sql, params=[])
    #   out = nil
    #   self.with_connection do |conn|
    #     if !params.empty?
    #       conn.exec_params(sql, [record.to_json])
    #     else
    #       conn.exec(sql)
    #     end
    #   end
    #   out
    # end

    # def self.new_collection_if_needed(domain, collection)
    #   did_change      = false
    #   table_name      = "records_#{domain}_#{collection}"
    #   index_name      = "cloudy_crud_records_#{domain}_#{collection}_data_path_ops"
    #   full_name_safe  = ''
    #   index_name_safe = ''
    #   domain_safe     = ''
    #   collection_safe = ''
      
    #   self.with_connection do |db|
    #     full_name_safe  = db.quote_ident(['cloudy_crud', table_name])
    #     index_name_safe = db.quote_ident(index_name)
    #     domain_safe     = db.escape_string(domain)
    #     collection_safe = db.escape_string(collection)
    #   end
      
    #   if !self.pg_class[:tables].include?(table_name)
    #     sql = %~
    #     CREATE TABLE #{full_name_safe} (
    #       CHECK ("domain" = '#{domain_safe}' AND "collection" = '#{collection_safe}')
    #     ) INHERITS ("cloudy_crud"."records");  ~
    #     self.with_connection {|c| c.exec(sql) }
    #     did_change = true
    #   end
      
    #   if !self.pg_class[:indices].include?(index_name)

    #     # TODO: CREATE INDEX asdf_admin_groups ON cloudy_crud.records_asdf USING GIN ((data #> '{permissions,admin,groups}'::text[] ));
    #     # TODO: CREATE INDEX asdf_admin_groups ON cloudy_crud.records_asdf USING GIN ((data #> '{permissions,admin,users}'::text[] ));
    #     # TODO: CREATE INDEX asdf_admin_groups ON cloudy_crud.records_asdf USING GIN ((data #> '{permissions,read,users}'::text[] ));
    #     # TODO: CREATE INDEX asdf_admin_groups ON cloudy_crud.records_asdf USING GIN ((data #> '{permissions,read,groups}'::text[] ));
        
    #     sql = %~
    #     CREATE INDEX
    #       #{index_name_safe}
    #       ON #{full_name_safe}
    #       USING GIN (data jsonb_path_ops); 
    #     ~
    #     self.with_connection {|c| c.exec(sql) }
    #     did_change = true
    #   end

    #   # Clear this cache since we changed the schema
    #   @@pg_class = nil if did_change
    #   full_name_safe
    # end
    
    
    # @@pg_class = nil # memoize
    # def self.pg_class
    #   return @@pg_class unless @@pg_class.nil?
    #   sql = %~
    #     SELECT
    #       c.relname,
    #       CASE c.relkind
    #         WHEN 'r' THEN 'tables'
    #         WHEN 'S' THEN 'sequences'
    #         WHEN 'i' THEN 'indices'
    #         WHEN 'v' THEN 'views'
    #         WHEN 'm' THEN 'materialized_views'
    #         WHEN 'c' THEN 'composite_types'
    #         WHEN 't' THEN 'toast_tables'
    #         WHEN 'f' THEN 'foreign_tables'
    #       END as kind
    #     FROM
    #       pg_namespace AS n,
    #       pg_class AS c
    #     WHERE
    #       nspname = 'cloudy_crud' AND
    #       c.relnamespace = n.oid
    #   ~      
    #   @@pg_class = {
    #     :tables             => [],
    #     :sequences          => [],
    #     :indices            => [],
    #     :views              => [],
    #     :materialized_views => [],
    #     :composite_types    => [],
    #     :toast_tables       => [],
    #     :foreign_tables     => []
    #   }
    #   self.with_connection do |conn|
    #     results = conn.exec(sql)
    #     results.each do |r|
    #       kind = r["kind"].to_sym
    #       @@pg_class[kind] << r["relname"]
    #     end
        
    #   end# connection
      
    #   @@pg_class
    # end
    
  end
end

