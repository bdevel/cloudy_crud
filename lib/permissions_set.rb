
module CloudyCrud

  # Allows passing a user or group object to the include?
  # and search through the IDs. Also when pushing, push
  # the ID and not the object
  class PermissionsSetArray < Array
    def initialize(collection, cast_as)
      @cast_as = cast_as
      super collection
    end
    
    def include?(obj)
      super @cast_as.ensure_instance(obj).id
    end
    
    def <<(obj)
      super @cast_as.ensure_instance(obj).id
    end
    
    def push(obj)
      super @cast_as.ensure_instance(obj).id
    end
    
  end
  
  class PermissionsSet
    include CloudyCrud::PermissionValidations
    attr_reader :users, :groups
    
    def initialize(**hash)
      @users  = PermissionsSetArray.new(hash[:users]  || hash["users"]  || [], CloudyCrud::User)
      @groups = PermissionsSetArray.new(hash[:groups] || hash["groups"] || [], CloudyCrud::UserGroup)
    end
    
    def include?(user)
      return true if users.include?(user)
      return true if groups.any? {|g| user_group_ids(user).include?(g) }
      return false
    end

    def to_h
      {
        user:   @users.to_a,
        groups: @groups.to_a,
      }
    end
    
    def self.build(params, user)
      self.ensure_nil_or_hash(params, "Permission")
      params = {} if params.nil?
      
      self.ensure_nil_or_array_of_values(params[:groups], "Permission groups")
      self.ensure_nil_or_array_of_values(params[:users],  "Permission users")

      user_obj = CloudyCrud::User.ensure_instance(user)
      if user_obj.id
        user_ids = [user_obj.id]
      else
        user_ids = []
      end
      
      # Take what came in from params or use the default
      self.new(
        groups: params[:groups] || [],
        users:  params[:users]  || user_ids
      )
    end

    private
    
    def user_group_ids(user)
      CloudyCrud::User.ensure_instance(user).groups.map(&:id)
    end
    
  end
end

