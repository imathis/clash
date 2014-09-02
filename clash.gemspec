# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'clash/version'

Gem::Specification.new do |spec|
  spec.name          = "clash"
  spec.version       = Clash::VERSION
  spec.authors       = ["Brandon Mathis"]
  spec.email         = ["brandon@imathis.com"]
  spec.summary       = %q{A diff based testing framework for static sites.}
  spec.description   = %q{A diff based testing framework for static sites.}
  spec.homepage      = "https://github.com/imathis/clash"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").grep(%r{(bin|lib)/})
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "diffy", "~> 3.0"
  spec.add_runtime_dependency "safe_yaml", "~> 1.0"
  spec.add_runtime_dependency "colorator", "~> 0.1"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "jekyll"
  spec.add_development_dependency "pry-debugger"
end
