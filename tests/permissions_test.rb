require_relative 'test_helpers'


describe CloudyCrud::Permissions do
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
    
    @user = TestUser.new
    @ccp = CloudyCrud::Permissions.build(@user, @params)
  end
  
  describe "#build" do
    
    it "should set acceptable defaults" do
      p = CloudyCrud::Permissions.build(@user)
      assert p.admin.groups.empty?
      assert p.read.groups.empty?
      assert p.write.groups.empty?
      
      assert p.admin.users.include?(@user.id)
      assert p.read.users.include?(@user.id)
      assert p.write.users.include?(@user.id)
    end
    
    it "should accept permissions from params" do
      p = CloudyCrud::Permissions.build(@user, @params)
      
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

  
  describe "#is_admin?" do
    it "is true for admins in users" do
      assert @ccp.is_admin?(TestUser.new(:id => "gene"))
    end
    
    it "is true for admins in groups" do
      assert @ccp.is_admin?(TestUser.new(:id => "xxxx", :groups => ['members'] ))
    end
    
    it "is false for non-admins" do
      refute @ccp.is_admin?(TestUser.new(:id => "xxxx", groups: ['zzzzz'] ))
    end
    
  end

  
  describe "#can_read?" do
    it "is true for admins in users" do
      assert @ccp.can_read?(TestUser.new(:id => "gene"))
    end
    
    it "is true for admins in groups" do
      assert @ccp.can_read?(TestUser.new(:id => "xxxx", :groups => ['members'] ))
    end
    
    it "is true for users in read" do
      assert @ccp.can_read?(TestUser.new(:id => "tommy"))
    end
    
    it "is true for groups in read" do
      assert @ccp.can_read?(TestUser.new(:id => "xxxx", :groups => ['groupies'] ))
    end
    
    it "is false for non-readers" do
      refute @ccp.can_read?(TestUser.new(:id => "xxxx", groups: ['zzzzz'] ))
    end
    
  end

  describe "#can_write?" do
    it "is true for admins in users" do
      assert @ccp.can_write?(TestUser.new(:id => "gene"))
    end
    
    it "is true for admins in groups" do
      assert @ccp.can_write?(TestUser.new(:id => "xxxx", :groups => ['members'] ))
    end
    
    it "is true for users in write" do
      assert @ccp.can_write?(TestUser.new(:id => "paul"))
    end
    
    it "is true for groups in write" do
      assert @ccp.can_write?(TestUser.new(:id => "xxxx", :groups => ['roadies'] ))
    end
    
    it "is false for non-writeers" do
      refute @ccp.can_write?(TestUser.new(:id => "xxxx", groups: ['zzzzz'] ))
    end
    
  end
  
  
  
end
