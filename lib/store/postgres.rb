
# http://ruby-journal.com/how-to-import-millions-records-via-activerecord-within-minutes-not-hours/


module CloudyCrud::Store
  class Postgres
    include CustomizableClassMethod
    SCHEMA_PREFIX=''
    
    customizable_class_method :with_connection do
      raise CloudyCrud::Error.new("CloudyCrud::Store::Postgres connection has not been configured.")
    end

    def self.execute(sql, params=[])
      out = nil
      self.with_connection do |conn|
        if !params.empty?
          conn.exec_params(sql, [record.to_json])
        else
          conn.exec(sql)
        end
      end
      out
    end
    
    def self.save(record)
      # create scheme and table if doesn't exist.
      if record._id
        sql = %~ UPDATE cloudy_crud.records
              SET updated_at = NOW(), data = $1::jsonb
              WHERE cloudy_crud.records.id = $2::int ~
        self.with_connection {|c| c.exec_params(sql, [record.to_json, record._id]) }
        
      else
        full_collection_name_safe = self.new_collection_if_needed(record.domain, record.collection)
        sql = %~ INSERT INTO #{full_collection_name_safe} (domain, collection, data, created_at, updated_at)
              VALUES ($1::text, $2::text, $3::jsonb, NOW(), NOW()) ~
        self.with_connection do |c|
          c.exec_params(sql, [record.domain, record.collection, record.to_json])
          record._id = c.exec('SELECT lastval()')[0]["lastval"].to_i
        end
      end
    end

    def self.destroy(record)
      if record._id
      else
        raise CloudyCrud::Error.new("Cannot destroy a record that has not been saved.")
      end
    end
    
    def self.find(query)
      sql = %~ SET constraint_exclusion = partition; -- Make query go to the right partition
            SELECT * FROM "cloudy_crud"."records"
            WHERE
              "domain"     = $1::text    AND
              "collection" = $2::text    AND
              "data"       @> $3::jsonb;
      ~
      self.with_connection do |conn|
        result = conn.exec_params(
          sql,
          [
            query.domain,
            query.collection,
            JSON.dump({id: query.id})
          ]
        )
      end
    end

    
    def self.schema_collection_path(domain, collection)
      # TODO: Ensure not ^pg_.*
    end

    def self.schema_setup
      sql = %~
      CREATE SCHEMA IF NOT EXISTS cloudy_crud;
      CREATE TABLE IF NOT EXISTS cloudy_crud.records (
        id         SERIAL,
        domain     TEXT,
        collection TEXT,
        created_at TIMESTAMP DEFAULT current_timestamp,
        updated_at TIMESTAMP DEFAULT current_timestamp,
        data       JSONB
      );
      ~
      self.with_connection do |conn|
        result = conn.exec(sql)
      end
    end

    def self.new_collection_if_needed(domain, collection)
      did_change      = false
      table_name      = "records_#{domain}_#{collection}"
      index_name      = "cloudy_crud_records_#{domain}_#{collection}_data_path_ops"
      full_name_safe  = ''
      index_name_safe = ''
      domain_safe     = ''
      collection_safe = ''
      
      self.with_connection do |db|
        full_name_safe  = db.quote_ident(['cloudy_crud', table_name])
        index_name_safe = db.quote_ident(index_name)
        domain_safe     = db.escape_string(domain)
        collection_safe = db.escape_string(collection)
      end
      
      if !self.pg_class[:tables].include?(table_name)
        sql = %~
        CREATE TABLE #{full_name_safe} (
          CHECK ("domain" = '#{domain_safe}' AND "collection" = '#{collection_safe}')
        ) INHERITS ("cloudy_crud"."records");  ~
        self.with_connection {|c| c.exec(sql) }
        did_change = true
      end
      
      if !self.pg_class[:indices].include?(index_name)
        sql = %~
        CREATE INDEX
          #{index_name_safe}
          ON #{full_name_safe}
          USING GIN (data jsonb_path_ops); 
        ~
        self.with_connection {|c| c.exec(sql) }
        did_change = true
      end

      # Clear this cache since we changed the schema
      @@pg_class = nil if did_change
      full_name_safe
    end
    
    
    @@pg_class = nil # memoize
    def self.pg_class
      return @@pg_class unless @@pg_class.nil?
      sql = %~
        SELECT
          c.relname,
          CASE c.relkind
            WHEN 'r' THEN 'tables'
            WHEN 'S' THEN 'sequences'
            WHEN 'i' THEN 'indices'
            WHEN 'v' THEN 'views'
            WHEN 'm' THEN 'materialized_views'
            WHEN 'c' THEN 'composite_types'
            WHEN 't' THEN 'toast_tables'
            WHEN 'f' THEN 'foreign_tables'
          END as kind
        FROM
          pg_namespace AS n,
          pg_class AS c
        WHERE
          nspname = 'cloudy_crud' AND
          c.relnamespace = n.oid
      ~      
      @@pg_class = {
        :tables             => [],
        :sequences          => [],
        :indices            => [],
        :views              => [],
        :materialized_views => [],
        :composite_types    => [],
        :toast_tables       => [],
        :foreign_tables     => []
      }
      self.with_connection do |conn|
        results = conn.exec(sql)
        results.each do |r|
          kind = r["kind"].to_sym
          @@pg_class[kind] << r["relname"]
        end
        
      end# connection
      
      @@pg_class
    end
    
  end
end

