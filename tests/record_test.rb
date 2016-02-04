require_relative 'test_helpers'
require "minitest/autorun"
begin
  require 'pry'
rescue
end


describe CloudyCrud::Record do
  before :each do
    DummyStore.reset!
    CloudyCrud.store = lambda {DummyStore}
    @user = TestUser.new
    @params = {
      user:       @user,
      domain:     'bdevel',
      collection: 'cars',
      type:       "cars",
      attributes: {
        manufacturerName: "Honda",
        year: 2002,
      }
    }
    @record = CloudyCrud::Record.new(@params)
  end


  describe "#to_json" do
    it "does proper" do
      skip
    end
  end

  describe "#[]=" do
    it "does proper" do
      skip
    end
  end
  
  describe "#new" do
    
    it "should set attributes and type" do
      assert_equal "cars", @record.type
      assert_equal "Honda", @record.manufacturer_name
      assert_equal 2002, @record.year
    end
    
    it "should not set set an external or extern id on initialization" do
      assert_equal nil, @record._id
      assert_equal nil, @record.id
    end
    
    it "should add permissions" do
      assert @record.permissions.is_admin?(@user)
      assert @record.permissions.can_read?(@user)
      assert @record.permissions.can_write?(@user)
    end
    
  end
  
  describe "#save" do
    it "should set an external id after saving" do
      @record.save
      assert_match /[a-z0-9]+\-[a-z0-9-]+/i, @record.id
    end
    
    it "should call Store.save" do
      @record.save
      assert_equal 1,         DummyStore.calls.size
      assert_equal :save,     DummyStore.calls.last[:method]
      assert_equal [@record], DummyStore.calls.last[:args]
    end
    
  end


  describe "#to_json" do
    it "does proper" do
      skip
    end
  end
  
end
