# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cyclical/version'

Gem::Specification.new do |gem|
  gem.name          = "cyclical"
  gem.version       = Cyclical::VERSION
  gem.authors       = ["Viktor Charypar"]
  gem.email         = ["charypar@gmail.com"]
  gem.description   = %q{Cyclical lets you list recurring events with complex recurrence rules like "every 4 years, the first Tuesday after a Monday in November" in a simple way.}
  gem.summary       = %q{Recurring events library for calendar applications.}
  gem.homepage      = "http://github.com/charypar/cyclical"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'active_support'
end
