require "recursive_case_indifferent_ostruct"
class CloudyCrud::Relationships

  def initialize(hash)
    @relations = RecursiveCaseIndifferentOstruct.new({}, CloudyCrud::Record::DEFAULT_CASE)
    hash.keys.each do |relation_name|
      @relations[relation_name] = CloudyCrud::Relationship.new(relation_name, hash[relation_name])
    end
  end
  
  def keys
    @relations.keys
  end

  def each(&block)
    @relations.each do |k, v|
      block.call(v)
    end
  end
  
  # get without doing fuzzy key matching
  def [](k)
    @relations[k]
  end
  
  # assign without doing fuzzy key matching
  def []=(k, v)
    @relations[k] = CloudyCrud::Relationship.ensure_instance(k, v)
  end

  # Get or assign by doing fuzzy key matching
  # be able to do record.relationships.foo_bar.add({type: 'foo-bars', id: 23})
  # be able to do record.relationships.foo_bar.add(another_record)
  def method_missing(method_name, args)
    if method_name.include?('=')
      @relations.send method_name, CloudyCrud::Relationship.ensure_instance(method_name, v)
    elsif (args.length == 0)
      # is a getter
      @relations.send(method_name)
    else
      super
    end
  end
  
end
