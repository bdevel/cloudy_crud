require_relative 'record'

class CloudyCrud::Relationship
  attr_accessor :name, :inverse, :type, :id, :attributes

  def initialize(**hash)
    @data = hash["data"] || hash[:data]
    @name = hash["name"] || hash[:name]
  end

  def add(**hash)
    if hash.is_a?(CloudyCrud::Record)
      #hash.id #hash.type
    end
    @data << {
      
    }
  end
  
  def to_h
    {
      data:  [ {type: "", id: ""}, {type: "", id: ""} ]
    }
  end


  def self.ensure_instance(name, hash_or_obj)
    if hash_or_obj.is_a?(CloudyCrud::Relationship)
      hash_or_obj
    else
      CloudyCrud::Relationship.new(name, hash_or_obj)
    end
  end
  
end
  

