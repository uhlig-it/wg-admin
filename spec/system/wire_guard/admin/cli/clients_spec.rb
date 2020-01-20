# frozen_string_literal: true

require 'tempfile'

# rubocop:disable RSpec/DescribeClass
describe 'wg-admin' do
  describe 'clients', type: 'aruba' do
    let(:network) { '192.168.10.0/24' }

    before do
      set_environment_variable 'WG_ADMIN_STORE', Tempfile.new.path
      set_environment_variable 'WG_ADMIN_NETWORK', network
      run_command_and_stop "wg-admin networks add #{network}"
    end

    it 'succeeds' do
      expect(last_command_started).to be_successfully_executed
    end

    it 'shows no errors' do
      expect(last_command_started.stderr).to be_empty, last_command_started.stderr
    end

    it 'auto-assigns the first IP address of the network' do
      run_command_and_stop 'wg-admin clients list'
      expect(last_command_started.stdout).to include('192.168.10.1')
    end

    it 'does not accept the same name twice'
    it 'does not accept the same ip twice'

    context 'when the wg executable is not found' do
      around do |example|
        with_environment 'PATH' => ENV['PATH'].split(':').reject { |e| e == '/usr/local/bin' }.join(':') do
          example.run
        end
      end

      fit 'does not succeed' do
        run_command_and_stop 'wg-admin clients add Alice'
warn "FOOOOOOO  - #{last_command_started.stdout}"
        run_command_and_stop 'which wg'
        expect(last_command_started).not_to be_successfully_executed
      end

      it 'prints a meaningful error message' do
        expect(last_command_started.stderr).to match(/not found in the PATH/), last_command_started.stderr
      end
    end
  end
  # rubocop:enable RSpec/DescribeClass
end
