# frozen_string_literal: true

require 'tempfile'
require 'ipaddr'

require 'wire_guard/admin/repository'
require 'wire_guard/admin/client'

describe WireGuard::Admin::Repository do
  subject(:repo) { described_class.new(Tempfile.new.path) }

  context 'when no network was added' do
    it 'has an empty list of networks' do
      expect(repo.networks).to be_empty
    end

    it 'does not accept a new peer' do
      expect { repo.add_peer(IPAddr.new('10.1.2.0'), 'somebody') }.to raise_error(WireGuard::Admin::Repository::UnknownNetwork)
    end

    it 'does not provide the next address' do
      expect { repo.next_address(IPAddr.new('10.1.2.0')) }.to raise_error(WireGuard::Admin::Repository::UnknownNetwork)
    end
  end

  context 'when network 10.1.2.0/24 was added' do
    let(:network) { IPAddr.new('10.1.2.0/24') }

    before { repo.add_network(network) }

    it 'lists the existing network' do
      expect(repo.networks).to include(network)
    end

    it 'finds the existing network' do
      expect(repo.find_network(network)).to eq(network)
    end

    it 'does provide the next address' do
      expect(repo.next_address(network)).to eq('10.1.2.1')
    end

    it 'refuses to add another peer with the same name to a network'

    context 'when a client exists within the known network' do
      let(:peer) { WireGuard::Admin::Client.new(name: 'somebody', ip: '10.1.2.11') }

      before do
        repo.add_peer(network, peer)
      end

      it 'knows it as peer' do
        expect(repo.find_peer(IPAddr.new('10.1.2.11/24'), 'somebody')).not_to be_nil
      end

      it 'lists it as client' do
        expect(repo.clients(network)).to include(peer)
      end
    end

    context 'when a server exists within the known network' do
      it 'knows it as peer'
      it 'lists it as server'
    end
  end
end
