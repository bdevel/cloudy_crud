require 'sinatra'
require 'pry'
require 'json'
set :port, 3000
set :bind, 'localhost'

@@data = {}

before do
  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST'],
          'Access-Control-Allow-Headers' => ['Content-Type', 'Accept', 'X-Requested-With', 'access_token']

  #env['rack.errors'] = error_logger
end


options '/api/v1/*' do
  
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
