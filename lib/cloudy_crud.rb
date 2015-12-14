module CloudyCrud
  class Error < ::Exception
  end

  class InvalidRequest < ::Exception
  end
  
  class Modification
    attr_accessor :attribute, :old_value, :updated_at
  end

  class Attributes
    
  end

  class User
    
  end
  
end




require_relative 'request_handler'
require_relative 'record'
require_relative 'permissions'

