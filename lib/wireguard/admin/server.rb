require 'wireguard/admin/client'

module Wireguard
  module Admin
    class Server < Client
      attr_accessor :port, :allowed_ips, :device

      def initialize(
          name:,
          ip:,
          private_key: nil,
          public_key: nil,
          port: 51820,
          allowed_ips: ,
          device: 'eth0'
        )
        super(name: name, ip: ip, private_key: private_key, public_key: public_key)

        raise ArgumentError, 'port must be present' if port.nil?
        raise ArgumentError, 'port number is invalid' unless (1..65535).cover?(port.to_i)
        @port = port.to_i

        raise ArgumentError, 'allowed_ips must be present' if allowed_ips.nil?
        self.allowed_ips = allowed_ips

        raise ArgumentError, 'device must be present' if device.nil?
        raise ArgumentError, 'device must not be empty' if device.empty?
        @device = device
      end

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
