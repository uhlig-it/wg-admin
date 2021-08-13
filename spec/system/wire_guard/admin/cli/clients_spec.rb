# frozen_string_literal: true

require 'pathname'

# rubocop:disable RSpec/DescribeClass
describe 'wg-admin' do
  describe 'clients', type: 'aruba' do
    let(:network) { '192.168.10.0/24' }

    context 'with a single network' do
      before do
        run_command_and_stop "wg-admin networks add #{network}"
      end

      context 'when adding a new client' do
        before do
          run_command_and_stop 'wg-admin clients add Alice'
        rescue RSpec::Expectations::ExpectationNotMetError => e
          warn "******** #{last_command_started.stderr}"
          raise e
        end

        it 'auto-assigns the first IP address of the network' do
          run_command_and_stop 'wg-admin clients list'
          expect(last_command_started.stdout).to include('192.168.10.1')
        end
      end
    end

    context 'when the network is set via environment variable' do
      before do
        set_environment_variable 'WG_ADMIN_NETWORK', network
        run_command_and_stop "wg-admin networks add #{network}"
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

        it 'fails when trying to add the same name again' do
          expect { run_command_and_stop 'wg-admin clients add Alice' }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        end
      end

      it 'does not accept the same ip twice'

      context 'when the wg executable is not found', skip: ENV['TRAVIS'] do
        let(:dir_of_wg) { `dirname $(which wg)`.chomp }

        around do |example|
          with_environment 'PATH' => ENV['PATH'].split(':').reject { |e| e == dir_of_wg }.join(':') do
            example.run
          end
        end

        it 'fails' do
          run_command_and_stop 'wg-admin clients add Alice'
          raise 'Command should have failed, but it did not'
        rescue RSpec::Expectations::ExpectationNotMetError
          expect(last_command_started).not_to be_successfully_executed
        end

        it 'prints a meaningful error message' do
          run_command_and_stop 'wg-admin clients add Alice'
          raise 'Command should have failed, but it did not'
        rescue RSpec::Expectations::ExpectationNotMetError
          expect(last_command_started.stderr).to match(/not found in the PATH/), last_command_started.stderr
        end
      end
    end
  end
  # rubocop:enable RSpec/DescribeClass
end
