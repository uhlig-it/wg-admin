# frozen_string_literal: true

require 'pathname'

# rubocop:disable RSpec/DescribeClass
describe 'wg-admin' do
  describe 'peers', type: 'aruba' do
    let(:network) { '192.168.10.0/24' }
    let(:store_path) { Pathname('/tmp/wg-admin-test') }

    before do
      store_path.unlink if store_path.exist?
      set_environment_variable 'WG_ADMIN_STORE', store_path.to_path
      set_environment_variable 'WG_ADMIN_NETWORK', network
      run_command_and_stop "wg-admin networks add #{network}"
    end

    context 'without peers' do
      it 'succeeds' do
        expect(last_command_started).to be_successfully_executed
      end

      it 'shows no errors' do
        expect(last_command_started.stderr).to be_empty
      end

      it 'shows no networks' do
        expect(last_command_started.stdout).to be_empty
      end
    end

    context 'when a client exists' do
      before do
        run_command_and_stop 'wg-admin client add Alice'
        run_command_and_stop 'wg-admin peers list'
      end

      it 'succeeds' do
        expect(last_command_started).to be_successfully_executed
      end

      it 'shows no errors' do
        expect(last_command_started.stderr).to be_empty
      end

      it "lists the client's name" do
        expect(last_command_started.stdout).to include('Alice')
      end
    end
  end
end
# rubocop:enable RSpec/DescribeClass
