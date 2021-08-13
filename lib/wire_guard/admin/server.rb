# frozen_string_literal: true

require 'wire_guard/admin/client'

module WireGuard
  module Admin
    #
    # A publicly reachable peer/node that serves as a fallback to relay traffic
    # for other VPN peers behind NATs.
    #
    #  @see https://github.com/pirate/wireguard-docs#bounce-server]
    #
    class Server < Client
      attr_reader :allowed_ips
      attr_accessor :port, :device

      # rubocop:disable Metrics/ParameterLists
      def initialize(
        name:,
        ip:,
        allowed_ips:,
        private_key: nil,
        port: 51_820,
        device: 'eth0'
      )
        super(name: name, ip: ip, private_key: private_key)

        raise ArgumentError, 'port must be present' if port.nil?
        raise ArgumentError, 'port number is invalid' unless (1..65_535).cover?(port.to_i)

        @port = port.to_i

        raise ArgumentError, 'allowed_ips must be present' if allowed_ips.nil?

        self.allowed_ips = allowed_ips

        raise ArgumentError, 'device must be present' if device.nil?
        raise ArgumentError, 'device must not be empty' if device.empty?

        @device = device
      end
      # rubocop:enable Metrics/ParameterLists

      def allowed_ips=(aips)
        raise ArgumentError, 'ip must be an IP address with prefix' unless aips.is_a?(IPAddr)

        @allowed_ips = aips
      end

      def to_s
        "#{self.class.name.split('::').last} #{name}: #{ip}:#{port} [Allowed IPs: #{allowed_ips}/#{allowed_ips.prefix} via #{device}]"
      end
    end
  end
end
