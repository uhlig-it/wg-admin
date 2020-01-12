require 'ipaddr'

module Wireguard
  module Admin
    class Client
      attr_reader :name, :ip

      def initialize(name:, ip:, private_key: nil, public_key: nil)
        raise ArgumentError, 'name must be present' if name.nil?
        raise ArgumentError, 'name must not be empty' if name.empty?
        @name = name

        raise ArgumentError, 'ip must be present' if ip.nil?

        if ip.is_a?(IPAddr)
          @ip = ip
        else
          @ip = IPAddr.new(ip)
        end

        raise ArgumentError, 'public_key must not be empty' if public_key && public_key.empty?
        @public_key = public_key

        raise ArgumentError, 'private_key must not be empty' if private_key && private_key.empty?
        @private_key = private_key
      end

      def private_key
        @private_key ||= %x(wg genkey)
      end

      def public_key
        @public_key ||= %x(echo #{private_key} | wg pubkey)
      end
    end
  end
end
