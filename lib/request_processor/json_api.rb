require_relative 'request_processor'
require 'json_stream_trigger'

class CloudyCrud::JsonApiProcessor < CloudyCrud::RequestProcessor
  def initialize(request)
    @request = request
  end
  
  def attributes
    @request.params[:attributes]
  end
  
  def build_record
    CloudyCrud::Record.build(
      domain:     domain,
      type:       type,
      attributes: attributes,
      user:       user
    )
  end
  
  def build_bulk(io, &block)
    stream = JsonStreamTrigger.new()
    
    stream.on('$.data[*]') do |json_string|
      hash = JSON.parse(json_string, :quirks_mode => true)
      block.call(processor.build_record)
    end
    
    while chunk = io.read(1024)
      stream << chunk
    end
  end
  
end


