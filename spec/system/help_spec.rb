# frozen_string_literal: true

describe 'help', type: 'aruba' do
  it 'prints usage' do
    run_command_and_stop 'wg-admin help'
    expect(last_command_started).to be_successfully_executed
    expect(last_command_started).to have_output(/Wireguard/)
  end
end
