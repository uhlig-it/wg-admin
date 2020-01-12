require 'ipaddr'
require 'open3'

module Wireguard
  module Admin
    InvocationError = Class.new(StandardError) do
      def initialize(lines)
        super(lines.first)
      end
    end

    ProgramNotFoundError = Class.new(StandardError) do
      def initialize
        super('wg was not found in the PATH. Perhaps it is not installed?')
      end
    end

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
        @private_key ||= generate_private_key
      end

      def public_key
        @public_key ||= generate_public_key
      end

      private

      def generate_public_key
        Open3.popen3('wg pubkey') do |stdin, stdout, stderr, waiter|
          stdin.write(private_key)
          stdin.close
          raise InvocationError.new(stderr.lines) unless waiter.value.success?
          stdout.read
        end
      rescue SystemCallError
        if $!.message =~ /No such file or directory/
          raise ProgramNotFoundError
        else
          raise
        end
      end

      def generate_private_key
        Open3.popen3('wg genkey') do |_, stdout, stderr, waiter|
          raise InvocationError.new(stderr.lines) unless waiter.value.success?
          stdout.read
        end
      rescue SystemCallError
        if $!.message =~ /No such file or directory/
          raise ProgramNotFoundError
        else
          raise
        end
      end
    end
  end
end
