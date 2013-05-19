# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json/patch/version'

Gem::Specification.new do |spec|
  spec.name          = "json-patch"
  spec.version       = Json::Patch::VERSION
  spec.authors       = ["Guille Carlos"]
  spec.email         = ["ramon.g.carlos@gmail.com"]
  spec.description   = %q{An implementation of RFC 6902: JSON Patch.}
  spec.summary       = %q{An implementation of RFC 6902: JSON Patch.}
  spec.homepage      = "https://github.com/guillec/json-patch"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
