# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require_relative 'lib/wire_guard/admin/version'

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name          = 'wireguard-admin'
  spec.version       = WireGuard::Admin::VERSION
  spec.authors       = ['Steffen Uhlig']
  spec.email         = ['steffen@familie-uhlig.net']
  spec.homepage      = 'https://github.com/suhlig/wireguard-admin'

  spec.summary       = 'WireGuard administration tool'
  spec.description   = %(wireguard-admin is an administration tool for WireGuard configuration.)
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'thor', '~> 1.0.1'

  spec.add_development_dependency 'aruba', '~> 0.14.14'
  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'guard', '~> 2.16.1'
  spec.add_development_dependency 'guard-bundler', '~> 3.0.0'
  spec.add_development_dependency 'guard-rspec', '~> 4.7.3'
  spec.add_development_dependency 'inifile', '~> 3.0.0'
  spec.add_development_dependency 'pry', '~> 0.12.2'
  spec.add_development_dependency 'pry-byebug', '~> 3.7.0'
  spec.add_development_dependency 'rake', '~> 13.0.1'
  spec.add_development_dependency 'rspec', '~> 3.9.0'
  spec.add_development_dependency 'rubocop', '~> 0.79.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.37.1'
end
# rubocop:enable Metrics/BlockLength
