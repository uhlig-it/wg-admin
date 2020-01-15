# frozen_string_literal: true

require 'tempfile'

describe 'list-networks', type: 'aruba' do
  before do
    set_environment_variable 'WG_ADMIN_STORE', Tempfile.new('wg-admin system test').path
    run_command_and_stop 'wg-admin list-networks'
  end

  context 'no network exists' do
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

  context 'a network exists' do
    let(:network) { '192.168.10.0/24' }

    before do
      run_command_and_stop "wg-admin add-network #{network}"
      run_command_and_stop 'wg-admin list-networks'
    end

    it 'succeeds' do
      expect(last_command_started).to be_successfully_executed
    end

    it 'shows no errors' do
      expect(last_command_started.stderr).to be_empty
    end

    it 'lists the network' do
      expect(last_command_started.stdout).to include('192.168.10.0/24')
    end
  end
end
