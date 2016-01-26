
module CloudyCrud
  class Error < ::Exception
  end

  class InvalidRequest < ::Exception
  end

  # can't use #customizable_class_method since this isn't a
  customizable_class_method :store do
    CloudyCrud::Store::Postgres
  end
  
end

require_relative 'customizable_class_method'
require_relative 'record'

require_relative 'user'
require_relative 'permissions'

