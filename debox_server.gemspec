# -*- encoding: utf-8 -*-
require File.expand_path('../lib/debox_server/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Eloy Gomez"]
  gem.email         = ["eloy@indeos.es"]
  gem.description   = "Centralized recipes manager for capistrano"
  gem.summary       = "Debox allow centralized recipes and secure deploy"
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "debox_server"
  gem.require_paths = ["lib"]
  gem.version       = DeboxServer::VERSION

  gem.add_runtime_dependency 'rake'
  gem.add_runtime_dependency 'rack'
  gem.add_runtime_dependency 'grape','~> 0.5.0'
  gem.add_runtime_dependency 'thin'
  gem.add_runtime_dependency 'json'
  gem.add_runtime_dependency 'capistrano', '~> 2.15.5'
  gem.add_runtime_dependency 'redis'
  gem.add_runtime_dependency 'activerecord', '~> 3.2.12'
  gem.add_runtime_dependency 'log4r'
  gem.add_runtime_dependency 'thor'
  gem.add_runtime_dependency 'jbuilder'
end
