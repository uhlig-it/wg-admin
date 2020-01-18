# frozen_string_literal: true

require 'wireguard/admin/client'
require 'ipaddr'

describe Wireguard::Admin::Client do
  subject(:client) { described_class.new(**args) }

  let(:args) do
    {
      name: 'Alice',
      ip: IPAddr.new('10.1.2.3')
    }
  end

  describe 'instantiation' do
    context 'when the name is missing' do
      before { args.delete(:name) }

      it_behaves_like('requiring valid args')
    end

    context 'when the name is nil' do
      before { args[:name] = nil }

      it_behaves_like('requiring valid args', /present/)
    end

    context 'when the name is empty' do
      before { args[:name] = '' }

      it_behaves_like('requiring valid args', /empty/)
    end

    context 'when the ip is missing' do
      before { args.delete(:ip) }

      it_behaves_like('requiring valid args')
    end

    context 'when the ip is nil' do
      before { args[:ip] = nil }

      it_behaves_like('requiring valid args', /present/)
    end

    context 'when the private_key is nil' do
      before { args[:private_key] = nil }

      it 'generates the private key' do
        expect(client.private_key).not_to be_empty
      end
    end

    context 'when the private_key is empty' do
      before { args[:private_key] = '' }

      it_behaves_like('requiring valid args', /empty/)
    end

    context 'when the public_key is nil' do
      before { args[:public_key] = nil }

      it 'generates the public key from the private one' do
        expect(client.public_key).not_to be_empty
      end
    end

    context 'when the public_key is empty' do
      before { args[:public_key] = '' }

      it_behaves_like('requiring valid args', /empty/)
    end
  end

  it 'has a name' do
    expect(client.name).to eq('Alice')
  end

  describe 'another client' do
    context 'when the args are the same' do
      let(:other) { described_class.new(**args) }

      it 'is the same object' do
        expect(client).to eq(other)
      end
    end

    context 'when the name is different' do
      let(:other) { described_class.new(**args.merge(name: 'Other Alice')) }

      it 'is another object' do
        expect(client).not_to eq(other)
      end
    end
  end

  describe 'the string representation' do
    it 'has the name' do
      expect(client.to_s).to include('Alice')
    end

    it 'has the IP address' do
      expect(client.to_s).to include('10.1.2.3')
    end
  end

  context 'when the there is no `wg` in the path' do
    it 'raises an error'
  end
end
