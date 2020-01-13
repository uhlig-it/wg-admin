# frozen_string_literal: true

require 'tempfile'

describe 'init', type: 'aruba' do
  before do
    set_environment_variable 'WG_ADMIN_STORE', Tempfile.new('wg-admin system test').path
    run_command_and_stop "wg-admin init #{args}"
  end

  context 'without arguments' do
    let(:args) { '' }

    it 'succeeds' do
      expect(last_command_started).to be_successfully_executed
    end

    it 'is silent' do
      expect(last_command_started.stderr).to be_empty
      expect(last_command_started.stdout).to be_empty
    end

    context 'with a verbose flag' do
      let(:args) { '--verbose' }

      it 'prints a message' do
        expect(last_command_started.stdout).to be_empty
        expect(last_command_started.stderr).to match(%r(10.0.0.0/8))
      end
    end
  end

  context 'with a network argument' do
    let(:args) { '--network 192.168.10.0/24' }

    it 'succeeds' do
      expect(last_command_started).to be_successfully_executed
    end

    it 'is silent' do
      expect(last_command_started.stderr).to be_empty
      expect(last_command_started.stdout).to be_empty
    end

    context 'with a verbose flag' do
      let(:args) { '--network 192.168.10.0/24 --verbose' }

      it 'prints a message' do
        expect(last_command_started.stdout).to be_empty
        expect(last_command_started.stderr).to match(%r(192.168.10.0/24))
      end
    end

    it 'refuses to initialize for a network that was already taken'
  end
end
