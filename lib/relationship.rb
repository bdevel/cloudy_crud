require "recursive_case_indifferent_ostruct"
require_relative 'record'

class CloudyCrud::Relationship
  def initialize(hash)
    #@data = hash["data"] || hash[:data]
    #@name = hash["name"] || hash[:name]
    @hash = RecursiveCaseIndifferentOstruct.new(hash, CloudyCrud::Record::DEFAULT_CASE)
    
  end
  
  def as_json
    @hash
  end

  def method_missing(method_name, *args)
    if method_name.to_s.include?('=')
      @hash.send method_name, args[0]
    elsif (args.length == 0)# is a getter
      @hash.send(method_name)
    else
      super
    end
  end
  
  
  # def self.ensure_instance(name, hash_or_obj)
  #   if hash_or_obj.is_a?(CloudyCrud::Relationship)
  #     hash_or_obj
  #   else
  #     CloudyCrud::Relationship.new(name, hash_or_obj)
  #   end
  # end
  
end
  

