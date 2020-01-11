require 'wireguard/admin/client'

describe Wireguard::Admin::Client do
  subject(:client) { described_class.new(**args) }

  let(:args) { {
      name: 'Alice',
      ip: '10.1.2.3',
      private_key: 'keep-it-super-s3cret',
      public_key: 'share-it-widely',
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

    context 'ip is invalid' do
      before { args[:ip] = '1.2.3' }
      it_behaves_like('requiring valid args', /invalid/)
    end

    context 'ip is an IPAddr object' do
      before { args[:ip] = IPAddr.new(args[:ip]) }

      it 'has the proper ip assigned' do
        expect(client.ip).to eq('10.1.2.3')
      end
    end

    context 'private_key is nil' do
      before { args[:private_key] = nil }
      it_behaves_like('requiring valid args', /present/)
    end

    context 'private_key is empty' do
      before { args[:private_key] = '' }
      it_behaves_like('requiring valid args', /empty/)
    end

    context 'public_key is nil' do
      before { args[:public_key] = nil }
      it_behaves_like('requiring valid args', /present/)
    end

    context 'public_key is empty' do
      before { args[:public_key] = '' }
      it_behaves_like('requiring valid args', /empty/)
    end
  end

  it 'has a name' do
    expect(client.name).to eq('Alice')
  end
end
