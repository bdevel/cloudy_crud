require_relative '../lib/cloudy_crud'
require "minitest/autorun"
require 'pg'

begin
  require 'pry'
rescue
end

# $dbconn = PG::Connection.open(:dbname => 'cloudy_crud_test')

# CloudyCrud::Store::Postgres.with_connection = lambda do |&block|
#   block.call($dbconn)
# end

# CloudyCrud::Store::Postgres.schema_setup



module DummyStore
  @@calls = []
  def self.reset!
    @@calls = []
  end

  def self.calls
    @@calls
  end
  
  def self.method_missing(method_name, *arguments, &block)
    @@calls << {:method => method_name, :args => arguments}
  end

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

