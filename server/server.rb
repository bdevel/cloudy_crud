require 'sinatra'
require 'pry'
require 'json'
#require_relative '../lib/rack/streaming_import'

set :port, 3000
set :bind, 'localhost'

@@data = {}

before do
  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST', 'PATCH'],
          'Access-Control-Allow-Headers' => ['Content-Type', 'Accept', 'X-Requested-With', 'access_token']

  #env['rack.errors'] = error_logger
end


# use Rack::StreamingImport, :foo => "foo value" do |username, password|
#   username == 'foo' && password == 'bar'
# end

# class MyCloudyCrudHanlder < CloudyCrud::BulkImportHandler
  
#   def start(request)
#     @db = ActiveRecord::Base.connection.raw_connection
#     @db.exec("COPY large_table (col1, col2, etc) FROM STDIN WITH CSV")

#     request[:foo]
#   end

#   def import(document)
#     @db.put_copy_data(file.readline)
#   end
  
#   def finish
#     # We are done adding copy data
#     @db.put_copy_end

#     # Display any error messages
#     while res = @db.get_result
#       if e_message = res.error_message
#         p e_message
#       end
#     end
#   end
  
# end

# use Rack::StreamingImport, :handler => MyCloudyCrudHanlder
class Foo
  def initialize(app, opts = {}, &block)
    @app  = app
  end
  def call(env)
    binding.pry
  end
end
use Foo


post "/" do
  
end

options '/api/v1/*' do
  content_type "application/vnd.api+json"
    JSON.pretty_generate(params)
end

get '/api/v1/*' do
  content_type "application/vnd.api+json"
  
  doc_type = params[:splat].first.split('/').first
  doc_id   = params[:splat].first.split('/')[1]
  
  @@data[doc_type] ||= []
  
  found = @@data[doc_type].reverse.select do |item|
    doc_id.nil? || item["data"]["id"].to_s == doc_id
  end
  
  if found.size == 1
    out = found.first
  else
    out = {"data" => found.map(){|d| d["data"]} }
  end
  binding.pry if out.nil?
  out["meta"] = {total: 123456}
  JSON.pretty_generate(out)
end

post '/api/v1/*' do
  content_type "application/vnd.api+json"
  status 201

  json     = JSON.parse(request.body.read)
  
  doc_type = params[:splat].first.split('/').first
  doc_id   = params[:splat].first.split('/')[1] || (rand() * 10000000).ceil
  
  json["data"]       ||= {}
  json["links"]      ||= {}
  json["data"]["id"]    = doc_id
  json["links"]["self"] = "/api/v1/#{doc_type}/#{doc_id}"
  
  @@data[doc_type] ||= []
  @@data[doc_type].push(json)
  
  
  #location '' # should retrurn location
  
  #binding.pry
  JSON.pretty_generate(json)
end


patch '/api/v1/*' do
  content_type "application/vnd.api+json"

  doc_type = params[:splat].first.split('/').first
  doc_id   = params[:splat].first.split('/')[1]

  @@data[doc_type] ||= []

  found = @@data[doc_type].reverse.select do |item|
    doc_id.nil? || item["data"]["id"].to_s == doc_id
  end

  if found.size == 1
    found[0] = JSON.parse(request.body.read)
    out = found.first
  else
    out = {"data" => found.map(){|d| d["data"]} }
  end
  binding.pry if out.nil?
  out["meta"] = {total: 123456}
    JSON.pretty_generate(out)
end
