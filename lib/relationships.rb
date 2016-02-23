require_relative 'relationship'

class CloudyCrud::Relationships

  def initialize(collection)
    collection = [] if collection.nil?
    @relations = collection.map do |hash|
      CloudyCrud::Relationship.new(hash)
    end
  end
  
  def each(&block)
    @relations.each do |r|
      block.call(r)
    end
  end

  def map(&block)
    @relations.map do |r|
      block.call(r)
    end
  end
  
  # Find by name
  def [](k)
    if k.is_a?(Fixnum)
      @relations[k]
    else
      @relations.select {|r| r.name == k.to_s }
    end
  end
  
  def as_json
    @relations.map do |r|
      r.as_json
    end
  end

  def add(name, hash)
    # TODO
  end
  
  # # Get or assign by doing fuzzy key matching
  # # be able to do record.relationships.foo_bar.add({type: 'foo-bars', id: 23})
  # # be able to do record.relationships.foo_bar.add(another_record)
  # def method_missing(method_name, *args)
  #   if method_name.to_s.include?('=')
  #     @relations.send method_name, CloudyCrud::Relationship.ensure_instance(method_name, v)
  #   elsif (args.length == 0)
  #     # is a getter
  #     @relations.send(method_name)
  #   else
  #     super
  #   end
  # end
  
end
