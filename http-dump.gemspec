# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'http-dump/version'

Gem::Specification.new do |spec|
  spec.name          = "http-dump"
  spec.version       = HTTPDump::VERSION
  spec.authors       = ["Yuichi Tateno"]
  spec.email         = ["hotchpotch@gmail.com"]
  spec.summary       = %q{Dump http request use WebMock.}
  spec.description   = %q{Dump http request use WebMock.}
  spec.homepage      = "https://github.com/hotchpotch/http-dump"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "webmock"
  spec.add_development_dependency "rspec", '~> 2.14'
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
