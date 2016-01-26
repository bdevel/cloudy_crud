
module CloudyCrud
  class PermissionsSet < OpenStruct
    include CloudyCrud::PermissionValidations
    
    def include?(user)
      return true if users.include? user_id(user)
      return true if groups.any? {|g| user_group_ids(user).include?(g) }
      return false
    end
    
    def self.build(params, user)
      self.ensure_nil_or_hash(params, "Permission")
      params = {} if params.nil?
      
      self.ensure_nil_or_array_of_values(params[:groups], "Permission groups")
      self.ensure_nil_or_array_of_values(params[:users], "Permission users")
      
      # Take what came in from params or use the default
      self.new(
        groups: (params[:groups] || []),
        users:  (params[:users]  || [user.id] )
      )
    end

    private
    
    def user_obj(user)
      @user_obj ||= CloudyCrud::User.ensure_instance(user)
    end
    
    def user_id(user)
      user_obj(user).id
    end
    
    def user_group_ids(user)
      user_obj(user).groups.map(&:id)
    end
  
  end
end

