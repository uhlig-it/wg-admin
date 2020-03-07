# frozen_string_literal: true

require 'pathname'
require 'inifile'

# rubocop:disable RSpec/DescribeClass
describe 'wg-admin' do
  describe 'config', type: 'aruba' do
    let(:network) { '192.168.42.0/24' }
    let(:store_path) { Pathname('/tmp/wg-admin-test') }

    before do
      store_path.unlink if store_path.exist?
      set_environment_variable 'WG_ADMIN_STORE', store_path.to_path
      set_environment_variable 'WG_ADMIN_NETWORK', network
      run_command_and_stop "wg-admin networks add #{network}"
    end

    context 'when just a single server exists' do
      before do
        run_command_and_stop 'wg-admin servers add wg.example.com'
      end

      it 'succeeds' do
        run_command_and_stop 'wg-admin config wg.example.com'
        expect(last_command_started).to be_successfully_executed
      end

      it 'shows no errors' do
        run_command_and_stop 'wg-admin config wg.example.com'
        expect(last_command_started.stderr).to be_empty
      end

      it 'prints the Address' do
        run_command_and_stop 'wg-admin config wg.example.com'
        config = IniFile.new(content: last_command_started.stdout)
        expect(config['Interface']).to include('Address' => '192.168.42.1/24')
      end

      it "prints the server's ListenPort" do
        run_command_and_stop 'wg-admin config wg.example.com'
        config = IniFile.new(content: last_command_started.stdout)
        expect(config['Interface']).to include('ListenPort' => 51_820)
      end

      # rubocop:disable RSpec/NestedGroups
      describe 'PrivateKey' do
        let(:config) { IniFile.new(content: last_command_started.stdout) }

        before do
          run_command_and_stop 'wg-admin config wg.example.com'
        end

        it 'exists' do
          expect(config['Interface']).to include('PrivateKey')
        end

        it 'is not empty' do
          expect(config['Interface']['PrivateKey']).not_to be_empty
        end
      end
      # rubocop:enable RSpec/NestedGroups

      it 'refuses to print the config of a non-existing server'
    end

    context 'when just a single client exists' do
      before do
        run_command_and_stop 'wg-admin clients add foo'
      end

      it 'prints the Address' do
        run_command_and_stop 'wg-admin config foo'
        expect(last_command_started.stdout).to include('Address = 192.168.42.1/24')
      end

      it 'lists the server as peer'
      it 'prints the PrivateKey'
    end

    context 'when a server and multiple clients exist' do
      before do
        run_command_and_stop 'wg-admin servers add wg.example.com'
        run_command_and_stop 'wg-admin clients add foo'
        run_command_and_stop 'wg-admin clients add bar'
        run_command_and_stop 'wg-admin clients add baz'
        run_command_and_stop 'wg-admin config foo'
      end

      let(:config) do
        IniFile.new(content: last_command_started.stdout)
      end

      # rubocop:disable RSpec/NestedGroups
      describe 'config for client foo' do
        it 'prints the PrivateKey'

        it 'prints the Address' do
          expect(config['Interface']).to include('Address' => '192.168.42.2/24')
        end

        it 'allows all clients to access the whole network' do
          expect(config['Peer']).to include('AllowedIPs' => '192.168.42.0/24')
        end
      end
      # rubocop:enable RSpec/NestedGroups

      it 'keeps the connection to the server alive' do
        expect(config['Peer']).to include('PersistentKeepalive' => 25)
      end
    end
  end
end
# rubocop:enable RSpec/DescribeClass
