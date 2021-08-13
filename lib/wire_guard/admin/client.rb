# frozen_string_literal: true

require 'open3'

module WireGuard
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

    #
    # A host that connects to the VPN and registers a VPN subnet address such as 192.0.2.3 for itself.
    #
    # @see https://github.com/pirate/wireguard-docs#peernodedevice
    #
    class Client
      attr_reader :name, :ip, :private_key, :public_key

      # rubocop:disable Metrics/PerceivedComplexity
      def initialize(name:, ip:, private_key: nil, public_key: nil)
        raise ArgumentError, 'name must be present' if name.nil?
        raise ArgumentError, 'name must not be empty' if name.empty?
        raise ArgumentError, 'ip must be present' if ip.nil?
        raise ArgumentError, 'private_key must not be empty' if private_key&.empty?
        raise ArgumentError, 'public_key must not be empty' if public_key&.empty?

        @name = name
        @ip = ip
        @private_key = private_key || generate_private_key
        @public_key = public_key || generate_public_key
      end
      # rubocop:enable Metrics/PerceivedComplexity

      def to_s
        "#{self.class.name.split('::').last} #{name}: #{ip}"
      end

      def hash
        name.hash
      end

      def eql?(other)
        hash == other.hash
      end

      def ==(other)
        name == if other.respond_to?(:name)
                  other.name
                else
                  other
                end
      end

      private

      def generate_public_key
        Open3.popen3('wg pubkey') do |stdin, stdout, stderr, waiter|
          stdin.write(private_key)
          stdin.close
          raise InvocationError, stderr.lines unless waiter.value.success?

          stdout.read.chomp
        end
      rescue SystemCallError => e
        raise ProgramNotFoundError if e.message =~ /No such file or directory/

        raise
      end

      def generate_private_key
        Open3.popen3('wg genkey') do |_, stdout, stderr, waiter|
          raise InvocationError, stderr.lines unless waiter.value.success?

          stdout.read.chomp
        end
      rescue SystemCallError => e
        raise ProgramNotFoundError if e.message =~ /No such file or directory/

        raise
      end
    end
  end
end
