require 'cloudy_crud'
require "minitest/autorun"
begin
  require 'pry'
rescue
end

class TestUser
  @@counter

  def initialize(**config)
    @@counter ||= 0
    @@counter += 1
    
    @id     = config[:id] || @@counter
    @config = config
  end
  
  def id
    @id
  end

  def groups
    if @config[:groups]
      @config[:groups].map{|id| TestGroup.new(id)}
    else
      []
    end
  end
  
end


class TestGroup
  attr_reader :id
  def initialize(id)
    @id = id
  end
end

