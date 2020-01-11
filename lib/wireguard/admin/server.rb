require 'wireguard/admin/client'

module Wireguard
  module Admin
    class Server < Client
      attr_reader :port, :network, :network_device

      def initialize(name:, ip:, private_key:, public_key:, port: 51820, network: '10.0.0.0/8', network_device: 'eth0')
        super(name: name, ip: ip, private_key: private_key, public_key: public_key)

        raise ArgumentError, 'port must be present' if port.nil?
        raise ArgumentError, 'port number is invalid' unless (1..65535).cover?(port.to_i)
        @port = port.to_i

        raise ArgumentError, 'network must be present' if network.nil?

        if network.is_a?(IPAddr)
          @network = network
        else
          @network = IPAddr.new(network)
        end

        raise ArgumentError, 'network_device must be present' if network_device.nil?
        raise ArgumentError, 'network_device must not be empty' if network_device.empty?
        @network_device = network_device
      end
    end
  end
end
