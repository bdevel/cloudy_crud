require_relative 'user_group'

class CloudyCrud::User
  include CustomizableClassMethod

  # TODO: How do I ensure this returns a cloudy crud user??
  customizable_class_method :find do |id|
    raise CloudyCrud::Error.new("CloudyCrud::User.find has not been configured.")
  end
  
  customizable_class_method :id do |user|
    user.id
  end
  
  customizable_class_method :groups do |user|
    [] # no groups by default.
  end

  def initialize(user)
    @user = user
  end
  
  def id
    self.class.id(@user)
  end

  def groups
    self.class.groups(@user)
  end
  
  # Make sure that user is an instance of CloudyCrud::User
  # otherwise decorate it.
  def self.ensure_instance(user)
    if user.is_a?(CloudyCrud::User)
      user
    else
      CloudyCrud::User.new(user)
    end
  end
  

end
