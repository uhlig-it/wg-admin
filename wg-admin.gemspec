# frozen_string_literal: true

require_relative 'lib/wire_guard/admin/version'

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name          = 'wg-admin'
  spec.version       = WireGuard::Admin::VERSION
  spec.authors       = ['Steffen Uhlig']
  spec.email         = ['steffen@familie-uhlig.net']
  spec.homepage      = 'https://github.com/uhlig-it/wg-admin'

  spec.summary       = 'WireGuard administration tool'
  spec.description   = %(wg-admin is an administration tool for WireGuard configuration.)
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'thor'

  spec.add_development_dependency 'aruba'
  spec.add_development_dependency 'bundler', '~>2.1'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'inifile'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
end
# rubocop:enable Metrics/BlockLength
