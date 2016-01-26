require 'rack'
require_relative 'response'

module CloudyCrud  
  class Request < Rack::Request
    include CloudyCrud::customizableClassMethod
    
    customizable_class_method :current_user do |req|
      raise CloudyCrud::Error.new("CloudyCrud::Request.current_user() {|req| ...} has not been configured.")
    end
    
    # def initialize(env)
    #   @env = env
    # end
    
    # def env;
    #   @env
    # end
    
    # def params
    #   path_params  = @env['action_dispatch.request.path_parameters'] || {}# for rails router
    #   query_params = Rack::Utils.parse_query(@env[QUERY_STRING].to_s)
    #   params       = path_params.merge(query_params)
      
    #   if params.respond_to?(:with_indifferent_access)
    #     params = params.with_indifferent_access # ActiveSupport provides this
    #   end
    #   params
    # end
    
    # def session
    #   @env['rack.session'] || {}
    # end


    def current_user
      @current_user ||= self.class.current_user(self)
    end
    
    def record_domain
      params[:_domain]
    end

    def record_collection
      params[:_collection]
    end

    def record_type
      
    end    
    
    def record_attributes
      
    end    
    
    
    # class methods
    class << self
      def get(env, user)
      end
      
      def post(env, user)
        record = Record.find_by_url(url)
      end
      
      def patch(env, user)
      end
      
      def delete(env, user)
      end
      
    end
    
  end
end
