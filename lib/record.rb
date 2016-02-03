require "recursive_case_indifferent_ostruct"
require 'json'
# r = Record.new()
# r.permissions.can_read?(user)
# r.relationships.cars = []

# curl -X PUT $HOST/_config/admins/anna -d '"secret"'

#{
# type: 'taxi_drivers',
# id:   'asdfg3-34sdf',
# relationships: [
#   {
#     name: "driver",
#     inverse: "cars",
#     type: "people",
#     id: 123
#   }
# ],
# permissions: {
#   admin: {
#     groups: [ ],
#     users: [
#       "tyler"
#     ]
#   },
#   read: {
#     groups: [ ],
#     users: [
#       "tyler"
#     ]
#   },
#   write: {
#     groups: [ ],
#     users: [
#       "tyler",
#       "gordon"
#     ]
#   }
# },
# attributes: {
#   name: 'Tyler'
# }
#}
class CloudyCrud::Record
  DEFAULT_CASE=:lower_camel
  DEFAULT_DOMAIN='cloudy_crud'
  
  def initialize(**record)
    @record = record
  end

  def inspect
    @record.inspect
  end
  
  def _id;        @record[:_id];  end # internal database ID
  def id;         @record[:id];   end
  def type;       @record[:type]; end
  def domain;     @record[:domain] || DEFAULT_DOMAIN; end
  def collection; @record[:collection] || type; end

  def _id=(v);        @record[:_id]        = v; end # internal database ID
  def id=(v);         @record[:id]         = v; end
  def type=(v);       @record[:type]       = v; end
  def domain=(v);     @record[:domain]     = v; end
  def collection=(v); @record[:collection] = v; end

  def user
    if @user.nil?
      if @record[:user].is_a?(Fixnum) || @record[:user].is_a?(String)
        @user = CloudyCrud::User.find(@record[:user])
      else
        @user = @record[:user]
      end
    end
    @user
  end
  
  def user=(user)
    @user          = user
    @record[:user] = user
  end
  
  def [](k); attributes[k]; end
  def []=(k,v); attributes[k] = v; end
  def attributes
    @attributes ||= RecursiveCaseIndifferentOstruct.new(@record[:attributes], DEFAULT_CASE)
  end
  
  def permissions
    @permissions ||= CloudyCrud::Permissions.build(user, @record[:permissions])
  end
  
  def relationships
    # select count(0) from cloudy_crud.records where data @> '{"relationships": {"author": {"data": [{"id": "122345", "type": "authors"}]}}}'::jsonb;
    @record[:relationships]
    #@relationships ||= CloudyCrud::Relationships.new(@record[:relationships])
  end
  
  def method_missing(meth, *args)
    meth_s = meth.to_s
    
    # if assigning
    if meth_s =~ /=$/
      # do the assignment to attributes
      attributes.send(meth, *args)
      
    elsif args.length > 0
      # raise exception if they passed it with arguments
      # as that's not a property we can get on the attributes
      super
    else
      # Must be a gtter
      attributes.send(meth)
    end
    
  end
  
  def save
    begin
      @record[:id] = self.class.generate_id
      CloudyCrud.store.save(self)
    rescue Exception => e
      self.id = nil # reset this
      raise e
    end
  end
  
  def destroy
    CloudyCrud.store.destroy(self)
  end

  def to_json
    JSON.dump(as_json)
  end
  
  def as_json(options={})
    {
      id:            id,
      type:          type,
      attributes:    attributes.to_h,
      relationships: relationships.to_h,
      permissions:   permissions.to_h
    }
  end
  
  # class methods
  class << self
    ID_SEGMENTS=3
    ID_SEGMENT_LENGTH=5
    
    # TODO
    def find(id, type)
      CloudyCrud.store.find(id, type)
    end
    
    # requesting_user, proposed_action (read/write/admin)
    #def find_by_url()
    #end
    
    def generate_id
      # Don't use zero, O, o, i, I, or 1 as they look alike
      chars      = 'abcdefghjkmnpqrstuvwxyz'+
                   '23456789' 
                   #'ABCDEFGHJKMNPQRSTUVWXYZ'
      out = ''
      
      ID_SEGMENTS.times do |i|
        ID_SEGMENT_LENGTH.times { out << chars[rand(chars.size)] }
        out += '-' if i != ID_SEGMENTS - 1
      end
      out
    end
    
  end
end

