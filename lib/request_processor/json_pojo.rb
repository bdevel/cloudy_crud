require_relative 'request_processor'
require 'json_stream_trigger'

class CloudyCrud::RequestProcessor::JsonPojo
  
  #def initialize(io)
  #  @io = io
  #end
  
  def self.process_bulk(io, &block)
    peek = io.read(10)
    if peek.gsub(/\s/, '')[0] == '['
      trigger = '$[*]' # Looks like this is a json array, use each item in array as new document
    else
      # Support having a base key of any name
      # match { anyKeyHere: [{...},{...},{...}] }
      trigger = '$.*[*]'
    end

    io.rewind # undo the peek
    
    stream = JsonStreamTrigger.new()
    stream.on(trigger) do |json_string|
      hash = JSON.parse(json_string, :quirks_mode => true)
      block.call(hash)
    end
    
    while chunk = io.read(1024)
      stream << chunk
    end
  end
  
end


