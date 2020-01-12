# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require_relative 'lib/wireguard/admin/version'

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name          = 'wireguard-admin'
  spec.version       = Wireguard::Admin::VERSION
  spec.authors       = ['Steffen Uhlig']
  spec.email         = ['steffen@familie-uhlig.net']
  spec.homepage      = 'https://github.com/suhlig/wireguard-admin'

  spec.summary       = 'Wireguard administration tool'
  spec.description   = %(wireguard-admin is an administration tool for Wireguard configuration.)
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'thor'

  spec.add_development_dependency 'aruba'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'

end
# rubocop:enable Metrics/BlockLength
