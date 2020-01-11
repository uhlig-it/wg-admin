# frozen_string_literal: true

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

  shared_examples 'requiring valid args' do |error_matcher|
    it 'does not allow instantiation' do
      expect { described_class.new(**args) }.to raise_error(ArgumentError, error_matcher || /missing/)
    end
  end
end
