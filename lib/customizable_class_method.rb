

module CustomizableClassMethod
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    @@defined_blocks = {}
    def customizable_class_method(name, &default_block)
      @@defined_blocks[name] = default_block

      # Define our class method assignment
      self.define_singleton_method(name.to_s + '=') do |new_block|
        @@defined_blocks[name] = new_block
      end

      # Define our class method handler
      self.define_singleton_method(name) do |*args, &b|
        @@defined_blocks[name].call(*args, &b)
      end
      
      # Define an instance method as well
      # Default is to pass self to block.
      #define_method(name) do |*args|
      #  puts "calling #{name} block"
      #  @@defined_blocks[name].call(self)
      #end
      
    end
  end# ClassMethods
  
end# CustomizableClassMethod



# class Foo
#   include CloudyCrud::CustomizableClassMethod
#   customizable_class_method :bar

#   def id
#     return '12345'
#   end
  
# end

# Foo.bar do |f|
#   puts f.id
# end

# x = Foo.new
# x.bar

