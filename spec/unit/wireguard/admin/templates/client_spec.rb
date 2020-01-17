require 'ipaddr'

require 'wireguard/admin/templates/client'
require 'wireguard/admin/client'

describe Wireguard::Admin::Templates::Client do
  subject(:template) { described_class.new(client, servers) }

  context 'no servers' do
    let(:client) { instance_double(
        Wireguard::Admin::Client,
        name: 'unit test',
        private_key: 'foobar',
        ip: IPAddr.new('1.2.3.4')
      )
    }
    let(:servers) { [] }

    it 'has an Interface section' do
      expect(template.render).to include('[Interface]')
    end

    it "has the client's private key" do
      expect(template.render).to include('PrivateKey = foobar')
    end

    it "has the client's IP address" do
      expect(template.render).to include('Address = 1.2.3.4/24')
    end
  end
end
