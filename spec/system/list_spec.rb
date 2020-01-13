# frozen_string_literal: true

require 'tempfile'

describe 'list', type: 'aruba' do
  context 'with initialization' do
    before do
      set_environment_variable 'WG_ADMIN_STORE', Tempfile.new('wg-admin system test').path
      run_command_and_stop 'wg-admin init'
      run_command_and_stop 'wg-admin list'
    end

    it 'succeeds' do
      expect(last_command_started).to be_successfully_executed
    end

    it 'shows no errors' do
      expect(last_command_started.stderr).to be_empty
    end

    it 'prints the network' do
      expect(last_command_started.stdout).to include('10.0.0.0/8')
    end

    context 'a client exists' do
      before do
        run_command_and_stop 'wg-admin add-client --name Alice'
        run_command_and_stop 'wg-admin list'
      end

      it "lists the client's name" do
        expect(last_command_started.stdout).to include('Alice')
      end

      it "lists the client's ip" do
        expect(last_command_started.stdout).to include('10.0.0.1')
      end
    end
  end
end
