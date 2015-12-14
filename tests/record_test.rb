require 'cloudy_crud'
require "minitest/autorun"
begin
  require 'pry'
rescue
end

# CloudyCrud::Record.stub :save do
#   @@count ||= 0
#   store_id    = @@count += 1
#   external_id = store_id
#   self
# end

class TestUser

  def initialize(config)
    @config = config
  end
  
  def id
    return @config[:id]
  end
  
end

describe CloudyCrud::Record do
  before do
    
  end
  
  describe "#build" do
    before do
      @params = {
        type: "cars",
        attributes: {
          make: "Honda",
          year: 2002,
        }
      }
      @user = TestUser.new({
                             :id => (rand() * 100000000).to_i #@@user_id_counter += 1,
                             
                           })# (random() * 100000000).to_i })
    end
    
    it "should set attributes and type" do
      record = CloudyCrud::Record.build(@params, @user)
      assert_equal "cars", record.type
      assert_equal "Honda", record.attributes.make
      assert_equal 2002, record.attributes.year
    end
    
    it "should build an external id" do
      record = CloudyCrud::Record.build(@params, @user)
      assert record.external_id.to_s.length > 0
    end
    
    it "should add permissions" do
      record = CloudyCrud::Record.build(@params, @user)
      assert record.permissions.admin.users.include?(@user.id)
      assert record.permissions.read.users.include?(@user.id)
      assert record.permissions.write.users.include?(@user.id)
    end
    
  end
  
  describe "#update" do
    
  end
  
end


        # relationships: [
        #   {
        #     name: "driver",
        #     inverse: "cars",
        #     type: "people",
        #     id: 123
        #   }
        # ],
        # #modifications: [
        # #  ['who what when oldValue']
        # #],
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
        # }
