# frozen_string_literal: true

require 'aruba/rspec'
require 'mkmf'

module Helpers
  #
  # Drop the directory where the given executable is found from the PATH.
  #
  # @returns the old path.
  #
  def drop_from_path(executable)
    orig_path = ENV['PATH']
    dir_to_be_dropped = File.dirname(MakeMakefile.find_executable(executable))
    ENV['PATH'] = ENV['PATH'].split(':').reject { |e| e == dir_to_be_dropped }.join(':')

    yield

    ENV['PATH'] = orig_path
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.include Helpers

  shared_examples 'requiring valid args' do |error_matcher|
    it 'does not allow instantiation' do
      expect { described_class.new(**args) }.to raise_error(ArgumentError, error_matcher || /missing/)
    end
  end
end
