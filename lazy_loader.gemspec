# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lazy_loader/version"

Gem::Specification.new do |gem|
  gem.name          = "lazy_loader"
  gem.version       = LazyLoader::GEM_VERSION
  gem.authors       = ["Peter Edge"]
  gem.email         = ["peter@locality.com"]
  gem.summary       = %{Lazy loading for Ruby and JRuby}
  gem.description   = %{Lazy loading for Ruby and JRuby, uses double-locking/volatile variable for JRuby, ||= otherwise}
  gem.homepage      = "https://github.com/centzy/lazy_loader"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "yard"
end
