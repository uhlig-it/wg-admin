require 'wireguard/admin/server'

describe Wireguard::Admin::Server do
  subject(:client) { described_class.new(**args) }

  let(:args) { {
      name: 'wg.example.com',
      ip: '10.1.2.3',
      private_key: 'keep-it-super-s3cret',
      public_key: 'share-it-widely',
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

    context 'network is nil' do
      before { args[:network] = nil }
      it_behaves_like('requiring valid args', /present/)
    end

    context 'network_device is nil' do
      before { args[:network_device] = nil }
      it_behaves_like('requiring valid args', /present/)
    end

    context 'network_device is empty' do
      before { args[:network_device] = '' }
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

  context 'no network provided' do
    it 'has the default network' do
      expect(client.network).to eq('10.0.0.0/8')
    end
  end

  context 'network IS provided' do
    before { args[:network] = '192.168.100.0/24' }

    it 'has the provided network' do
      expect(client.network).to eq('192.168.100.0/24')
    end
  end

  context 'network is an IPAddr object' do
    before { args[:network] = IPAddr.new('10.11.0.0/16') }

    it 'has the proper network assigned' do
      expect(client.network).to eq('10.11.0.0/16')
    end
  end

  context 'no network_device provided' do
    it 'has the default network device' do
      expect(client.network_device).to eq('eth0')
    end
  end

  context 'network_device IS provided' do
    before { args[:network_device] = 'eth1' }

    it 'has the provided network device' do
      expect(client.network_device).to eq('eth1')
    end
  end
end
