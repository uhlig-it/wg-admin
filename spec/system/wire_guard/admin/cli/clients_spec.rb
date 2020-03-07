# frozen_string_literal: true

require 'tempfile'

# rubocop:disable RSpec/DescribeClass
describe 'wg-admin' do
  describe 'clients', type: 'aruba' do
    context 'when the network is set via environment variable' do
      let(:network) { '192.168.10.0/24' }
      let(:store_path) { Tempfile.new.path }

      before do
        set_environment_variable 'WG_ADMIN_STORE', store_path
        set_environment_variable 'WG_ADMIN_NETWORK', network
        run_command_and_stop "wg-admin networks add #{network}"
      end

      it 'succeeds' do
        expect(last_command_started).to be_successfully_executed
      end

      it 'shows no errors' do
        expect(last_command_started.stderr).to be_empty, last_command_started.stderr
      end

      context 'when adding a new client' do
        before do
          run_command_and_stop 'wg-admin clients add Alice'
        end

        it 'auto-assigns the first IP address of the network' do
          run_command_and_stop 'wg-admin clients list'
          expect(last_command_started.stdout).to include('192.168.10.1')
        end
      end

      it 'does not accept the same name twice'
      it 'does not accept the same ip twice'

      context 'when the wg executable is not found' do
        around do |example|
          with_environment 'PATH' => ENV['PATH'].split(':').reject { |e| e == '/usr/local/bin' }.join(':') do
            example.run
          end
        end

        it 'prints a meaningful error message' do
          run_command_and_stop 'wg-admin clients add Alice'
          fail 'Command should have failed, but it did not'
        rescue RSpec::Expectations::ExpectationNotMetError => e
          expect(last_command_started).not_to be_successfully_executed
          expect(last_command_started.stderr).to match(/not found in the PATH/), last_command_started.stderr
        end
      end
    end
  end
  # rubocop:enable RSpec/DescribeClass
end
