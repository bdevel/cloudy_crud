require 'ostruct'
require_relative 'permission_validations'
require_relative 'permissions_set'

module CloudyCrud
  class Permissions < OpenStruct
    include CloudyCrud::PermissionValidations
    
    def new(hash)
      # Map the read, write, admin into PermissionSet objects
      params = hash.dup
      hash.each do |k, v|
        params[k] = PermissionsSet.new(v)
      end
      super params
    end
    
    def is_admin?(user)
      admin.include?(user)
    end
    
    def can_read?(user)
      read.include?(user) || is_admin?(user)
    end
    
    def can_write?(user)
      write.include?(user) || is_admin?(user)
    end
    
    
    # Takes params from a POST/PATCH and a user
    # and creates a new Permissions object.
    def self.build(user, params=nil)
      self.ensure_nil_or_hash(params, "Permission")
      params = {} if params.nil?
      
      self.new(
        admin: PermissionsSet.build(params[:admin], user),
        read:  PermissionsSet.build(params[:read],  user),
        write: PermissionsSet.build(params[:write], user)
      )
    end
    
  end
end
