# frozen_string_literal: true

require 'tempfile'

describe 'config', type: 'aruba' do
  let(:network) { '192.168.42.0/24' }

  before do
    set_environment_variable 'WG_ADMIN_STORE', Tempfile.new('wg-admin system test').path
    set_environment_variable 'WG_ADMIN_NETWORK', network
    run_command_and_stop "wg-admin add-network #{network}"
  end

  context 'just a single server exists' do
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

    it "prints the Address" do
      run_command_and_stop 'wg-admin config wg.example.com'
      expect(last_command_started.stdout).to include('Address = 192.168.42.1/24')
    end

    it "prints the server's ListenPort" do
      run_command_and_stop 'wg-admin config wg.example.com'
      expect(last_command_started.stdout).to include('ListenPort = 51820')
    end

    it "prints the PrivateKey"
    it 'refuses to print the config of a non-existing server'
  end

  context 'just a single client exists' do
    before do
      run_command_and_stop 'wg-admin add-client foo'
    end

    it "prints the Address" do
      run_command_and_stop 'wg-admin config foo'
      expect(last_command_started.stdout).to include('Address = 192.168.42.1/24')
    end

    it 'lists the server as peer'
    it "prints the PrivateKey"
  end

  context 'a server and multiple clients exist' do
    before do
      run_command_and_stop 'wg-admin add-server wg.example.com'
      run_command_and_stop 'wg-admin add-client foo'
      run_command_and_stop 'wg-admin add-client bar'
      run_command_and_stop 'wg-admin add-client baz'
    end

    describe 'config for client foo' do
      before do
      end

      it "prints the PrivateKey"

      it "prints the Address" do
        run_command_and_stop 'wg-admin config foo'
        expect(last_command_started.stdout).to include('Address = 192.168.42.2/24')
      end

      it 'allows all clients to access the whole network' do
        run_command_and_stop 'wg-admin config foo'
        # TODO just within a [Peer] section
        expect(last_command_started.stdout).to include('AllowedIPs = 192.168.42.0/24')
      end
    end

    it 'keeps the connection to the server alive' do
      run_command_and_stop 'wg-admin config foo'
      # TODO just within a [Peer] section
      expect(last_command_started.stdout).to include('PersistentKeepalive = 25')
    end
  end
end
