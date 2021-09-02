# frozen_string_literal: true

require 'ipaddr'

require 'wire_guard/admin/templates/client'
require 'wire_guard/admin/client'

describe WireGuard::Admin::Templates::Client do
  subject(:template) { described_class.new(
    client: client,
    network: network,
    servers: servers)
  }

  context 'with no servers' do
    let(:client) do
      instance_double(
        WireGuard::Admin::Client,
        name: 'unit test',
        private_key: 'foobar',
        ip: IPAddr.new('1.2.3.4')
      )
    end

    let(:servers) { [] }
    let(:network) { IPAddr.new('1.2.3.0/24') }

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
