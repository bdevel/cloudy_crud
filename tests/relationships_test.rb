require_relative 'test_helpers'
require "minitest/autorun"

$relationship_counter = 0

describe CloudyCrud::Relationships do
  before :each do
    @params = {
      fatherInLaw: {
        data: {
          type: "father-in-laws",
          id:  $relationship_counter += 1,
          attributes: {
            createdAt: Time.now
          }
        }
      }
    }
    @record = CloudyCrud::Record.new(@params)
  end


  describe "#to_json" do
    it "does proper" do
      skip
    end
  end
  
end
