require 'rack/utils'
require 'zlib'

require_relative 'upload_handlers/json_api'
#require_relative 'upload_handlers/json_pojo'
#require_relative 'upload_handlers/csv'

begin
  require 'pry'
rescue
end

module Rack
  class CloudyCrudBulkImport
    VERSION = '0.1.0'
    def initialize(app, opts = {}, &block)
      @app  = app
      @opts = opts
      @handler = @opts[:handler]
    end

    def call(env)
      req = CloudyCrud::Request.new(env)
      
      io     = self.class.get_io(env)
      parser = self.class.get_upload_parser(req)
      
      parser.process(io) do |doc|
        record = CloudyCrud::Record.build({
                                            type:        path_params[:_collection],
                                            attributes:  doc,
                                            _domain:     path_params[:_domain],
                                            _collection: path_params[:_collection]
                                          }, req.current_user )
      end
      
      @app.call(env)
    end

    # TODO: IT would be nice if I could add my own handlers via config
    def self.get_upload_parser(req)
      upload_format = self.upload_format(req)
      if upload_format == :json_api
        Rack::BulkImport::UploadHandlers::JsonApi
        
      elsif upload_format == :json_pojo
        Rack::BulkImport::UploadHandlers::JsonPojo
        
      elsif upload_format == :csv
        Rack::BulkImport::UploadHandlers::Csv
        
      else
        raise CloudyCrud::Error.new("Unknown upload format: #{upload_format}")
      end
      
    end

    # tells which parser to use
    def self.upload_format(req)
      content_type = req.content_type || ''
      if content_type.to_s.downcase == "application/vnd.api+json"
        :json_api
      elsif content_type.to_s.downcase =~/json/
        :json_pojo
      elsif content_type.to_s.downcase =~ /csv/
        :csv
      else
        raise CloudyCrud::Error.new("Bulk import with content type '#{content_type}' is not supported")
      end
    end
    
    # Will unzip if sent compressed
    def self.get_io(env)
      if env['HTTP_CONTENT_ENCODING'] == 'gzip'
        Zlib::GzipReader.new(env['rack.input'])
      else
        env['rack.input']
      end
    end
    
  end
end

# env['rack.input']

# env['rack.input'].gets


# tempfile = Tempfile.new('raw-upload.', @tmpdir)

# # Can't get to produce a test case for this :-(
# env['rack.input'].each do |chunk|
#   if chunk.respond_to?(:force_encoding)
#     tempfile << chunk.force_encoding('UTF-8')
#   else
#     tempfile << chunk
#   end
# end
# env['rack.input'].rewind

# tempfile.flush
# tempfile.rewind


