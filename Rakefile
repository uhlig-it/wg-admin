# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'bundler/gem_tasks'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

namespace :spec do
  desc 'Run CI tests'
  task ci: %i[rubocop unit system]

  %w[unit system].each do |type|
    desc "Run #{type} tests"
    RSpec::Core::RakeTask.new(type) do |t|
      t.pattern = "spec/#{type}/**/*_spec.rb"
    end
  end
end

task default: 'spec:ci'
