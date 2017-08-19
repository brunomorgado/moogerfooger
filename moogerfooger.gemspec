# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'moogerfooger/version'

Gem::Specification.new do |spec|
  spec.name          = "moogerfooger"
  spec.version       = Moogerfooger::VERSION
  spec.authors       = ["Bruno Morgado"]
  spec.email         = ["brunofcmorgado@gmail.com"]

  spec.summary       = %q{Go wild on modularizing your iOS applications.}
  spec.description   = %q{MoogerFooger is a tool that provides straight forward modularization for iOS Apps. It works by linking multiple git repositories.}
  spec.homepage      = "https://github.com/brunomorgado/moogerfooger"
  spec.license       = "MIT"

  spec.files        = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md ROADMAP.md CHANGELOG.md)
  spec.executables  = ['mooger']
  spec.require_path = 'lib'

  spec.add_dependency "thor"

	spec.add_development_dependency "bundler", "~> 1.14"
	spec.add_development_dependency "rake", "~> 10.0"
	spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "fakefs", "~> 0.11.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "byebug", "~> 9.0.6"
end
