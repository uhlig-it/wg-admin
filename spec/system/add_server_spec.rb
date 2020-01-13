# frozen_string_literal: true

require 'tempfile'

describe 'add-server', type: 'aruba' do
  context 'without initialization' do
    it 'raises an error'
  end

  context 'with initialization' do
    before do
      set_environment_variable 'WG_ADMIN_STORE', Tempfile.new('wg-admin system test').path
      run_command_and_stop 'wg-admin init --network 192.168.10.0/24'
      run_command_and_stop 'wg-admin add-server --name wg.example.com'
    end

    it 'succeeds' do
      expect(last_command_started).to be_successfully_executed
    end

    it 'shows no errors' do
      expect(last_command_started.stderr).to be_empty
    end

    it 'auto-assigns the first IP address of the network' do
      run_command_and_stop 'wg-admin list'
      expect(last_command_started.stdout).to include('192.168.10.1')
    end

    it 'does not accept the same name twice'
    it 'does not accept the same ip twice'
  end
end
