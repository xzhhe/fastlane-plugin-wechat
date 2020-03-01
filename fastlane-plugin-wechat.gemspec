# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/wechat/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-wechat'
  spec.version       = Fastlane::Wechat::VERSION
  spec.author        = 'xiongzenghui'
  spec.email         = 'zxcvb1234001@163.com'

  spec.summary       = 'this is a wechat api wrapper'
  spec.homepage      = "https://github.com/xzhhe/fastlane-plugin-wechat"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  # spec.add_dependency 'your-dependency', '~> 1.0.0'

  spec.add_development_dependency('rake')
  spec.add_development_dependency('pry')
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rubocop')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('fastlane')
end
