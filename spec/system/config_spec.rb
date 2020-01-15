# frozen_string_literal: true

require 'tempfile'

describe 'config', type: 'aruba' do
  let(:network) { '192.168.42.0/24' }

  before do
    set_environment_variable 'WG_ADMIN_STORE', Tempfile.new('wg-admin system test').path
    set_environment_variable 'WG_ADMIN_NETWORK', network
    run_command_and_stop "wg-admin add-network #{network}"
  end

  context 'a server exists' do
    before do
      run_command_and_stop 'wg-admin add-server wg.example.com'
    end

    it 'succeeds' do
      run_command_and_stop 'wg-admin config wg.example.com'
      expect(last_command_started).to be_successfully_executed
    end

    it 'shows no errors' do
      run_command_and_stop 'wg-admin config wg.example.com'
      expect(last_command_started.stderr).to be_empty
    end

    it "prints the server's Address" do
      run_command_and_stop 'wg-admin config wg.example.com'
      expect(last_command_started.stdout).to include('Address = 192.168.42.1/24')
    end

    it "prints the server's ListenPort"
    it "prints the server's PrivateKey"
  end
end
