# frozen_string_literal: true

require 'tempfile'

# rubocop:disable RSpec/DescribeClass
describe 'networks', type: 'aruba' do
  before do
    set_environment_variable 'WG_ADMIN_STORE', Tempfile.new.path
    run_command_and_stop 'wg-admin networks list'
  end

  context 'when no network exists' do
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

  context 'when a new network is added' do
    let(:network) { '192.168.10.0/24' }

    before do
      run_command_and_stop "wg-admin networks add #{network}"
    end

    it 'succeeds' do
      expect(last_command_started).to be_successfully_executed
    end

    it 'shows no errors' do
      expect(last_command_started.stderr).to be_empty
    end

    it 'lists the network that was just added' do
      run_command_and_stop 'wg-admin networks list'
      expect(last_command_started.stdout).to include('192.168.10.0/24')
    end
  end

  context 'when requesting verbose logging' do
    it 'says which database file is used'
    it 'says which network was added'
    it 'says how many networks there are now'
  end
end
# rubocop:enable RSpec/DescribeClass
