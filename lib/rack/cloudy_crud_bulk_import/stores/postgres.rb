module Rack:CloudyCrudBulkImport
  module Stores
    module Postgres
      
      def start(connection)
        @db = connection
        @db.exec("COPY large_table (user_id, created_at, data) FROM STDIN WITH CSV")
        
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
        @db.put_copy_data(file.readline)
      end
      
      def finish
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


