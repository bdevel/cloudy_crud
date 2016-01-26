require 'cloudy_crud'
require "minitest/autorun"
begin
  require 'pry'
rescue
end


describe CloudyCrud::Record do
  before do
    
  end
  
  describe "#build" do
    before do
      @params = {
        type: "cars",
        attributes: {
          manufacturerName: "Honda",
          year: 2002,
        }
      }
      @user = TestUser.new
    end
    
    it "should set attributes and type" do
      record = CloudyCrud::Record.build(@params, @user)
      assert_equal "cars", record.type
      assert_equal "Honda", record.manufacturer_name
      assert_equal 2002, record.year
    end
    
    it "should build an external id" do
      record = CloudyCrud::Record.build(@params, @user)
      assert record.id.to_s.length > 0
    end
    
    it "should add permissions" do
      record = CloudyCrud::Record.build(@params, @user)
      assert record.permissions.is_admin?(@user)
      assert record.permissions.can_read?(@user)
      assert record.permissions.can_write?(@user)
    end
    
  end
  
  describe "#update" do
    
  end
  
end
