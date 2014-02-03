# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kaitatari/version'

Gem::Specification.new do |spec|
  spec.name          = "kaitatari"
  spec.version       = Kaitatari::VERSION
  spec.authors       = ["Pierre Tremouilhac"]
  spec.email         = ["p.tremouilhac@gmail.com"]
  spec.description   = "data processing"
  spec.summary       = ""
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
