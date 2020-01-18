# frozen_string_literal: true

require 'wire_guard/admin/server'
require 'ipaddr'

describe WireGuard::Admin::Server do
  subject(:client) { described_class.new(**args) }

  let(:args) do
    {
      name: 'wg.example.com',
      ip: IPAddr.new('10.1.2.3'),
      allowed_ips: IPAddr.new('10.1.2.3/8')
    }
  end

  describe 'instantiation' do
    context 'when the port is nil' do
      before { args[:port] = nil }

      it_behaves_like('requiring valid args', /present/)
    end

    context 'when the port is 0' do
      before { args[:port] = '' }

      it_behaves_like('requiring valid args', /invalid/)
    end

    context 'when the port is not within the allowed range' do
      before { args[:port] = 123_456_789 }

      it_behaves_like('requiring valid args', /invalid/)
    end

    context 'when the allowed_ips are nil' do
      before { args[:allowed_ips] = nil }

      it_behaves_like('requiring valid args', /present/)
    end

    context 'when the device is nil' do
      before { args[:device] = nil }

      it_behaves_like('requiring valid args', /present/)
    end

    context 'when the device is empty' do
      before { args[:device] = '' }

      it_behaves_like('requiring valid args', /empty/)
    end
  end

  context 'without port' do
    it 'has the default port' do
      expect(client.port).to eq(51_820)
    end
  end

  context 'when the port IS provided' do
    before { args[:port] = 53 }

    it 'has the provided port' do
      expect(client.port).to eq(53)
    end
  end

  context 'when no allowed_ips are provided' do
    xit 'allows the whole network' do
      expect(client.allowed_ips).to eq('10.0.0.0/8')
    end
  end

  context 'when allowed_ips ARE provided' do
    before { args[:allowed_ips] = IPAddr.new('10.11.0.0/16') }

    it 'has the proper allowed_ips assigned' do
      expect(client.allowed_ips).to eq('10.11.0.0/16')
    end
  end

  context 'without device' do
    it 'has the default device' do
      expect(client.device).to eq('eth0')
    end
  end

  context 'when the device IS provided' do
    before { args[:device] = 'eth1' }

    it 'has the provided device' do
      expect(client.device).to eq('eth1')
    end
  end
end
