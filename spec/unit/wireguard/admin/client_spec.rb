require 'wireguard/admin/client'
require 'ipaddr'

describe Wireguard::Admin::Client do
  subject(:client) { described_class.new(**args) }

  let(:args) { {
      name: 'Alice',
      ip: IPAddr.new('10.1.2.3'),
    }
  }

  describe 'instantiation' do
    context 'name is missing' do
      before { args.delete(:name) }
      it_behaves_like('requiring valid args')
    end

    context 'name is nil' do
      before { args[:name] = nil }
      it_behaves_like('requiring valid args', /present/)
    end

    context 'name is empty' do
      before { args[:name] = '' }
      it_behaves_like('requiring valid args', /empty/)
    end

    context 'ip is missing' do
      before { args.delete(:ip) }
      it_behaves_like('requiring valid args')
    end

    context 'ip is nil' do
      before { args[:ip] = nil }
      it_behaves_like('requiring valid args', /present/)
    end

    context 'private_key is nil' do
      before { args[:private_key] = nil }

      it 'generates the private key' do
        expect(client.private_key).to_not be_empty
      end
    end

    context 'private_key is empty' do
      before { args[:private_key] = '' }
      it_behaves_like('requiring valid args', /empty/)
    end

    context 'public_key is nil' do
      before { args[:public_key] = nil }

      it 'generates the public key from the private one' do
        expect(client.public_key).to_not be_empty
      end
    end

    context 'public_key is empty' do
      before { args[:public_key] = '' }
      it_behaves_like('requiring valid args', /empty/)
    end
  end

  it 'has a name' do
    expect(client.name).to eq('Alice')
  end

  it 'has a string representation' do
    expect(client.to_s).to include('Alice')
    expect(client.to_s).to include('10.1.2.3')
  end

  context 'there is no `wg` in the path' do
    it 'raises an error'
  end
end
