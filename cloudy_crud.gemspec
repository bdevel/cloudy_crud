Gem::Specification.new do |s|
  s.name        = 'cloudy_crud'
  s.version     = '0.1'
  s.date        = '2015-07-01'
  s.summary     = ""
  s.description = ""
  s.authors     = ["Tyler Roberts"]
  s.email       = 'code@polar-concepts.com'
  s.files       = Dir['README.md', 'lib/**/*']
  s.homepage    = 'http://github.com/bdevel/cloudy_crud'
  s.license     = 'MIT'

  s.add_runtime_dependency "recursive_case_indifferent_ostruct", '~> 0'
  s.add_runtime_dependency 'json_stream_trigger', '~> 0'
  s.add_runtime_dependency 'sequel', '<5.0.0'

end

