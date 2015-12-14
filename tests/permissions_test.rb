require 'cloudy_crud'
require "minitest/autorun"
begin
  require 'pry'
rescue
end


class TestUser

  def initialize(**config)
    @config = config
  end
  
  def id
    return @config[:id]
  end
  
end

describe CloudyCrud::Permissions do
  before do
    
  end
  
  describe "#build" do
    before do
      @params = {
        admin: {
          groups: ['members'],
          users: [
            "gene"
          ]
        },
        read: {
          groups: ['groupies'],
          users: [
            "tommy"
          ]
        },
        write: {
          groups: ['roadies'],
          users: [
            "paul"
          ]
        }
      }
      
      @user = TestUser.new(
        :id => (rand() * 100000000).to_i
      )
    end
    
    it "should set acceptable defaults" do
      p = CloudyCrud::Permissions.build(nil, @user)
      assert p.admin.groups.empty?
      assert p.read.groups.empty?
      assert p.write.groups.empty?
      
      assert p.admin.users.include?(@user.id)
      assert p.read.users.include?(@user.id)
      assert p.write.users.include?(@user.id)
    end
    
    it "should accept permissions from params" do
      p = CloudyCrud::Permissions.build(@params, @user)
      
      assert_equal @params[:admin][:groups], p.admin.groups
      assert_equal @params[:read][:groups],  p.read.groups
      assert_equal @params[:write][:groups], p.write.groups
      assert_equal @params[:admin][:users],  p.admin.users
      assert_equal @params[:read][:users],   p.read.users
      assert_equal @params[:write][:users],  p.write.users
    end
    
  end
  
  describe "#update" do
    
  end
  
end
