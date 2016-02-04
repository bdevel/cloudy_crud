require_relative 'user_group'

class CloudyCrud::User
  include CustomizableClassMethod

  # TODO: How do I ensure this returns a cloudy crud user??
  customizable_class_method :find do |id|
    raise CloudyCrud::Error.new("CloudyCrud::User.find has not been configured.")
  end
  
  customizable_class_method :id do |user|
    if user
      user.id
    else
      nil
    end
  end
  
  customizable_class_method :groups do |user|
    if user.respond_to?(:groups)
      user.groups
    else
      []
    end
  end

  def initialize(user)
    @user = user
  end
  
  def id
    self.class.id(@user)
  end

  def groups
    self.class.groups(@user).map {|g| CloudyCrud::UserGroup.ensure_instance(g)}
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
