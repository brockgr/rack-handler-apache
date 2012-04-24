Gem::Specification.new do |s|
  s.name        = 'rack-handler-apache'
  s.version     = '0.0.1'
  s.date        = '2010-04-28'
  s.summary     = "Rack::Handle::Apache"
  s.description = "A rack-handler like gem for apache/passenger"
  s.authors     = ["Gavin Brock"]
  s.email       = 'gavin@brock-family.org'
  s.files       = Dir["lib/**/*.rb", "*.md"]
  s.homepage    = 'https://github.com/brockgr/rack-handler-apache'

  s.add_dependency "rack"
  s.add_dependency "ttyname"
  s.add_dependency "passenger"
end

