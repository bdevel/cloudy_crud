
module CloudyCrud::Store
  class Postgres
    include CustomizableClassMethod
    SCHEMA_PREFIX=''
    
    customizable_class_method :connection do
      raise CloudyCrud::Error.new("CloudyCrud::Store::Postgres connection has not been configured.")
    end
    
    def self.save(record)
      # create scheme and table if doesn't exist.
      if record[:_id]
        'UPDATE'
      else
        self.connection 'INSERT'
      end
    end

    def self.destroy(record)
      if record[:_id]
      else
        raise CloudyCrud::Error.new("Cannot destroy a record that has not been saved.")
      end
    end

    def self.find(id=nil)
      collection = self.connection.quote_ident([query.domain, query.collection])
      
      sql = "SELECT * FROM #{collection} " +
            "WHERE data @> $1::json"

      if id
        query = {:id => id}
      end
      
      result = exec_params(sql, [query.to_json])
      
      # select ('{"a":1,"b": 34 }'::json #>> '{b}')::int = 2;
      
    end
    
    def self.configure
      
    end

    def self.schema_collection_path(domain, collection)
      # TODO: Ensure not ^pg_.*
    end

    def self.migrations
      "CREATE SCHEMA cloudy_crud;"
      "CREATE TABLE records (" +
        "created_at time," +
        "updated_at time," +
        "data JSON)"
    end

    def self.new_collection(domain, collection)
      "CREATE TABLE #{escape(collection)} (

       ) INHERITS (cloudy_crud.records)"
    end
    
  end
end

