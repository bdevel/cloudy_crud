require_relative 'response'

module CloudyCrud  
  class RequestHandler
    # class methods
    class << self
      def get(url, params)
      end
      
      def post(url, params)
        
        record = Record.find_by_url(url)
        
      end
      
      def patch(url, params)
      end
      
      def delete(url, params)
      end
      
    end
    
  end
end
