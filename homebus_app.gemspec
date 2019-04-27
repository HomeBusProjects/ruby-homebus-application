Gem::Specification.new do |s|
  s.name        = 'homebus_app'
  s.version     = '0.0.13'
  s.licenses    = ['MIT']
  s.summary     = 'Ruby library for HomeBus applications'
  s.description = 'Library for building HomeBus applications in Ruby'
  s.authors     = ['John Romkey']
  s.email       = 'romkey+ruby@romkey.com'
  s.files       = ['lib/homebus_app.rb', 'lib/homebus_app_options.rb']
  s.homepage    = 'https://homebus.org/'
  s.metadata    = { 'source_code_uri' => 'https://github.com/romkey/ruby-homebus-app' }
  s.add_runtime_dependency 'dotenv'
end
