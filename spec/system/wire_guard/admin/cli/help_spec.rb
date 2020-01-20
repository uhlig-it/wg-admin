# frozen_string_literal: true

# rubocop:disable RSpec/DescribeClass
describe 'wg-admin' do
  describe 'help', type: 'aruba' do
    before do
      run_command_and_stop 'wg-admin help'
    end

    it 'runs fine' do
      expect(last_command_started).to be_successfully_executed
    end

    it 'prints usage' do
      expect(last_command_started).to have_output(/WireGuard/)
    end
  end
  # rubocop:enable RSpec/DescribeClass
end
