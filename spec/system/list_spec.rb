# frozen_string_literal: true

require 'aruba/rspec'
require 'tempfile'

describe 'list', type: 'aruba' do
  context 'with initialization' do
    before do
      ENV['WG_ADMIN_STORE'] = Tempfile.new('wg-admin system test').path
      run_command 'wg-admin init'
      run_command 'wg-admin list'
      stop_all_commands
    end

    it 'succeeds' do
      expect(last_command_started).to be_successfully_executed
    end

    it 'shows no error messages' do
      expect(last_command_started.stderr).to be_empty
    end

    it 'prints the network' do
      expect(last_command_started.stdout).to match(%r(10.0.0.0/8))
    end
  end
end
