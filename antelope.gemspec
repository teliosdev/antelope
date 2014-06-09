# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'antelope/version'

Gem::Specification.new do |spec|
  spec.name          = "antelope"
  spec.version       = Antelope::VERSION
  spec.authors       = ["Jeremy Rodi"]
  spec.email         = ["redjazz96@gmail.com"]
  spec.summary       = %q{A compiler compiler, written in ruby.}
  spec.description   = %q{A compiler compiler, written in ruby.}
  spec.homepage      = "https://github.com/medcat/antelope"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "liquid", "~> 2.6"
  spec.add_dependency "sourcify", "~> 0.5"
  spec.add_dependency "hashie", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-its"
end
