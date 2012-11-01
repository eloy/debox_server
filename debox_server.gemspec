# -*- encoding: utf-8 -*-
require File.expand_path('../lib/debox_server/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Eloy Gomez"]
  gem.email         = ["eloy@indeos.es"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "debox_server"
  gem.require_paths = ["lib"]
  gem.version       = DeboxServer::VERSION

  gem.add_runtime_dependency 'rake'
  gem.add_runtime_dependency 'sinatra'
  gem.add_runtime_dependency 'sinatra-contrib'
  gem.add_runtime_dependency 'thin'
  gem.add_runtime_dependency 'json'
  gem.add_runtime_dependency 'capistrano'

  # Development dependencies
  gem.add_development_dependency 'rspec'

end
