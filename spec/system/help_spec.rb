# frozen_string_literal: true

require 'aruba/rspec'

describe 'help', type: 'aruba' do
  it 'prints usage' do
    run_command 'wg-admin help'
    expect(last_command_started).to be_successfully_executed
    expect(last_command_started).to have_output(/Wireguard/)
  end
end
