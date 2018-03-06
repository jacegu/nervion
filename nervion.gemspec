# -*- encoding: utf-8 -*-
require File.expand_path('../lib/nervion/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Javier Acero"]
  gem.email         = ["j4cegu@gmail.com"]
  gem.description   = %q{A minimalistic Ruby client for the Public Streams of Twitter Streaming API}
  gem.summary       = %q{Nervions is an easy tool and lightweight tool for consuming Twitter's Public Streams with an API that mimics the provided endpoints}
  gem.homepage      = "https://github.com/jacegu/nervion"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec|features)/})
  gem.name          = "nervion"
  gem.require_paths = ["lib"]
  gem.version       = Nervion::VERSION

  gem.add_runtime_dependency 'eventmachine', '~> 1.0.0.rc.4'
  gem.add_runtime_dependency 'http_parser.rb', '~> 0.5.3'
  gem.add_runtime_dependency 'yajl-ruby', '~> 1.3.1'
  gem.add_development_dependency 'cucumber'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'yard'
end
