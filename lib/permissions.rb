require 'ostruct'
require_relative 'validations'


class CloudyCrud::Permissions < OpenStruct
  include CloudyCrud::Validation
  
  class PermissionsSet < OpenStruct
    include CloudyCrud::Validation
    
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
  end
  
  
  # Takes params from a POST/PATCH and a user
  # and creates a new Permissions object.
  def self.build(params, user)
    
    self.ensure_nil_or_hash(params, "Permission")
    params = {} if params.nil?
    
    self.new(
      admin: PermissionsSet.build(params[:admin], user),
      read:  PermissionsSet.build(params[:read],    user),
      write: PermissionsSet.build(params[:write],   user)
    )
  end
  
end

