# -*- encoding: utf-8 -*-
require File.expand_path('../lib/nervion/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Javier Acero"]
  gem.email         = ["j4cegu@gmail.com"]
  gem.description   = %q{A Twitter Stream API client}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec|features)/})
  gem.name          = "nervion"
  gem.require_paths = ["lib"]
  gem.version       = Nervion::VERSION

  gem.add_runtime_dependency 'http_parser.rb', '~> 0.5.3'
  gem.add_runtime_dependency 'yajl-ruby', '~> 1.1.0'
  gem.add_development_dependency 'rspec'
end
