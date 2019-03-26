Gem::Specification.new do |s|
  s.name        = 'despecable'
  s.version     = '0.3.1'
  s.date        = '2018-01-05'
  s.summary     = "Easy self-documenting parameter specifications for API routes in Rails"
  s.description = "Write self-documenting parameter validation and type-casting in your API actions. Docs and development at https://github.com/ozydingo/despecable."
  s.authors     = ["Andrew Schwartz"]
  s.email       = 'ozydingo@gmail.com'
  s.files       = Dir["lib/**/*"]
  s.homepage    = 'https://github.com/ozydingo/despecable'
  s.license     = 'MIT'

  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "pry", '~> 0.10.4'
  s.add_development_dependency "actionpack"
end
