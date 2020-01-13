require 'wireguard/admin/server'

describe Wireguard::Admin::Server do
  subject(:client) { described_class.new(**args) }

  let(:args) { {
      name: 'wg.example.com',
      ip: '10.1.2.3',
    }
  }

  describe 'instantiation' do
    context 'port is nil' do
      before { args[:port] = nil }
      it_behaves_like('requiring valid args', /present/)
    end

    context 'port is 0' do
      before { args[:port] = '' }
      it_behaves_like('requiring valid args', /invalid/)
    end

    context 'port is not within the allowed range' do
      before { args[:port] = 123456789 }
      it_behaves_like('requiring valid args', /invalid/)
    end

    context 'allowed_ips is nil' do
      before { args[:allowed_ips] = nil }
      it_behaves_like('requiring valid args', /present/)
    end

    context 'device is nil' do
      before { args[:device] = nil }
      it_behaves_like('requiring valid args', /present/)
    end

    context 'device is empty' do
      before { args[:device] = '' }
      it_behaves_like('requiring valid args', /empty/)
    end
  end

  context 'no port provided' do
    it 'has the default port' do
      expect(client.port).to eq(51820)
    end
  end

  context 'port IS provided' do
    before { args[:port] = 53 }

    it 'has the provided port' do
      expect(client.port).to eq(53)
    end
  end

  context 'no allowed_ips provided' do
    it 'has the default allowed_ips' do
      expect(client.allowed_ips).to eq('10.0.0.0/8')
    end
  end

  context 'allowed_ips IS provided' do
    before { args[:allowed_ips] = '192.168.100.0/24' }

    it 'has the provided allowed_ips' do
      expect(client.allowed_ips).to eq('192.168.100.0/24')
    end
  end

  context 'allowed_ips is an IPAddr object' do
    before { args[:allowed_ips] = IPAddr.new('10.11.0.0/16') }

    it 'has the proper allowed_ips assigned' do
      expect(client.allowed_ips).to eq('10.11.0.0/16')
    end
  end

  context 'no device provided' do
    it 'has the default device' do
      expect(client.device).to eq('eth0')
    end
  end

  context 'device IS provided' do
    before { args[:device] = 'eth1' }

    it 'has the provided device' do
      expect(client.device).to eq('eth1')
    end
  end
end
