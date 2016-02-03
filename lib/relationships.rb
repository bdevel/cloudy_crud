
class CloudyCrud::Relationships

  def initialize(hash)
    
  end
  
  # be able to do record.relationships.foo_bar.add({type: 'foo-bars', id: 23})
  # be able to do record.relationships.foo_bar.add(another_record)
  
  def method_missing(method_name, args)
    if method_name.include?('=')
    end
  end
  
end
