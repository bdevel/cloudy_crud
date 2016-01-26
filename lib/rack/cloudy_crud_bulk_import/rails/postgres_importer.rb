module Rack:BulkImport
  module Rails
    class PostgresImporter
      import Rack:BulkImport::Stores::Postgres
      
      def start(request)
        @store = Rack:BulkImport::Stores::Postgres.new(ActiveRecord::Base.connection.raw_connection)
        
        # collection
        # 
        
        # "id",
        # "owner",
        # "uri",
        # "data",
        # "status",
        # "created_at",
        # "updated_at",
        # "object_type",
        # "uri_id"
        
      end

      def import(document)
        record = RecordBuilder.new(document)
        record.attributes.keys
        
        @store.start if @sent
        
        @db.exec("COPY large_table (user_id, created_at, data) FROM STDIN WITH CSV")
        
        @db.put_copy_data(file.readline)
      end
      
      def finish
        @store.finish
        # We are done adding copy data
        @db.put_copy_end

        # Display any error messages
        while res = @db.get_result
          if e_message = res.error_message
            p e_message
          end
        end
      end
      
    end
  end
  
end
