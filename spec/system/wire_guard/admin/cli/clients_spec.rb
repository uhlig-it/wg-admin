# frozen_string_literal: true

require 'tempfile'

# rubocop:disable RSpec/DescribeClass
describe 'clients', type: 'aruba' do
  let(:network) { '192.168.10.0/24' }

  before do
    set_environment_variable 'WG_ADMIN_STORE', Tempfile.new.path
    set_environment_variable 'WG_ADMIN_NETWORK', network
    run_command_and_stop "wg-admin networks add #{network}"
    run_command_and_stop 'wg-admin clients add Alice'
  end

  it 'succeeds' do
    expect(last_command_started).to be_successfully_executed
  end

  it 'shows no errors' do
    expect(last_command_started.stderr).to be_empty
  end

  it 'auto-assigns the first IP address of the network' do
    run_command_and_stop 'wg-admin clients list'
    expect(last_command_started.stdout).to include('192.168.10.1')
  end

  it 'does not accept the same name twice'
  it 'does not accept the same ip twice'
end
# rubocop:enable RSpec/DescribeClass