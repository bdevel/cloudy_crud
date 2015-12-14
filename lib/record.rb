require 'ostruct'

# module MagicAttributes
#   def self.included(base)
#     base.extend(ClassMethods)
#   end

#   module ClassMethods



#     def magic_attributes(*attrs)
#       attrs = attrs.first if attrs.is_a?(Array)

#       attrs.each_key do |attr_name|
#         if attrs[attr_name].is_a?(Array)
#           define_method(attr_name) do
#             calls = attrs[attr_name].dup
#             obj = self # start with the current object
#             calls.each do |call|
#               obj = obj.send(call)
#               return nil if obj.nil?
#             end
#             return obj
#           end

#         elsif attrs[attr_name].is_a?(Proc)
#           define_method(attr_name) do
#             attrs[attr_name].call(self)
#           end
#         else
#           # Else just return the value
#           define_method(attr_name) do
#             attrs[attr_name]
#           end
#         end
#       end


#     end
#   end

# end

#r = Record.new()
#r.permissions.can_read?(user)
#r.relationships.cars = []

class CloudyCrud::Record
  #attr_accessor :type, :external_id, :created_at, :updated_at, :modifications
  
  def initialize(**record)
    @record = record
  end
  
  def type
    @record[:type]
  end
  
  def attributes
    @attributes ||= OpenStruct.new(@record[:attributes])
  end

  def external_id
    @record[:external_id]
  end
  
  def permissions
    @record[:permissions]
  end
  
  # class methods
  class << self
    def find(type, id)
    end
    
    # requesting_user, proposed_action (read/write/admin)
    def find_by_url()
      
    end
    
    def generate_external_id
      segments   = 2
      seg_length = 5
      # Don't use zero, O, o, i, I, or 1 as they look alike
      chars      = 'abcdefghjkmnpqrstuvwxyz'+
                   '23456789' +
                   'ABCDEFGHJKMNPQRSTUVWXYZ'
      out = ''
      
      segments.times do |i|
        seg_length.times { out << chars[rand(chars.size)] }
        out += '-' if i != segments - 1
      end
      out
    end

    # Take params from POST/PATCH, and a user and returns
    # a new un-saved record.
    def build(params, user)
      self.new({
                 type: params[:type],
                 attributes: params[:attributes],
                 external_id: self.generate_external_id,
                 permissions: CloudyCrud::Permissions.build(
                   params[:permissions], user
                 )
               })
    end
    
  end
end
