# frozen_string_literal: true

require 'tempfile'

describe 'list-peers', type: 'aruba' do
  let(:network) { '192.168.10.0/24' }

  before do
    set_environment_variable 'WG_ADMIN_STORE', Tempfile.new('wg-admin system test').path
    set_environment_variable 'WG_ADMIN_NETWORK', network
    run_command_and_stop "wg-admin add-network #{network}"
  end

  context 'no peers' do
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

  context 'a client exists' do
    before do
      run_command_and_stop 'wg-admin add-client Alice'
      run_command_and_stop 'wg-admin list-peers'
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

    it "lists the client's ip" do
      expect(last_command_started.stdout).to include('192.168.10.1')
    end
  end
end
