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
  
end
  

