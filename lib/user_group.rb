
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

  def self.ensure_instance(group)
    if group.is_a?(CloudyCrud::UserGroup)
      group
    else
      CloudyCrud::UserGroup.new(group)
    end
  end
    
end

