# frozen_string_literal: true

require 'aruba/rspec'
require 'tempfile'

describe 'list', type: 'aruba' do
  context 'with initialization' do
    before do
      ENV['WG_ADMIN_STORE'] = Tempfile.new('wg-admin system test').path
      run_command 'wg-admin init'
      run_command 'wg-admin list'
      stop_all_commands
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
        run_command 'wg-admin add-client --name Alice'
        run_command 'wg-admin list'
        stop_all_commands
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
