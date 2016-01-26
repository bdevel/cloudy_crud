
class CloudyCrud::UserGroup
  include CustomizableClassMethod
  customizable_class_method :id do |group|
    group.id
  end
  
  def initialize(group)
    @group = group
  end
  
  def id
    self.class.id(@group)
  end

  
end

