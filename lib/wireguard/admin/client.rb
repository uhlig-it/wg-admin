require 'ipaddr'

module Wireguard
  module Admin
    class Client
      attr_reader :name, :ip, :private_key, :public_key

      def initialize(name:, ip:, private_key:, public_key:)
        raise ArgumentError, 'name must be present' if name.nil?
        raise ArgumentError, 'name must not be empty' if name.empty?
        @name = name

        raise ArgumentError, 'ip must be present' if ip.nil?

        if ip.is_a?(IPAddr)
          @ip = ip
        else
          @ip = IPAddr.new(ip)
        end

        raise ArgumentError, 'public_key must be present' if public_key.nil?
        raise ArgumentError, 'public_key must not be empty' if public_key.empty?
        @public_key = public_key

        raise ArgumentError, 'private_key must be present' if private_key.nil?
        raise ArgumentError, 'private_key must not be empty' if private_key.empty?
        @private_key = private_key
      end
    end
  end
end
