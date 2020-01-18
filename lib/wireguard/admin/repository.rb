# frozen_string_literal: true

require 'pstore'

module Wireguard
  module Admin
    #
    # The place where networks, clients and servers can be found and are persisted
    #
    class Repository
      #
      # Raised if the network was not specified
      #
      class NetworkNotSpecified < StandardError
        def initialize
          super('Network not specified')
        end
      end

      #
      # Raised if the network is not known
      #
      class UnknownNetwork < StandardError
        def initialize(unknown)
          super("Network #{unknown} is unknown")
        end
      end

      #
      # Raised if the network already exists
      #
      class NetworkAlreadyExists < StandardError
        def initialize(existing)
          super("Network #{existing} already exists")
        end
      end

      attr_reader :path

      def initialize(path)
        @path = path
        @backend = PStore.new(@path)
      end

      #
      # Get all networks
      #
      def networks
        @backend.transaction do
          @backend.roots
        end
      end

      #
      # Find a network within all known ones
      #
      def find_network(network)
        raise ArgumentError, 'network must be an IP address range' unless network.is_a?(IPAddr)

        networks.select { |n| n == network }.first
      end

      #
      # Find a peer by name within the given network
      #
      def find_peer(network, name)
        raise ArgumentError, 'network must be an IP address range' unless network.is_a?(IPAddr)

        peers(network).select { |p| p.name == name }.first
      end

      #
      # Get all peers of the given network
      #
      def peers(network)
        raise ArgumentError, 'network must be an IP address range' unless network.is_a?(IPAddr)

        @backend.transaction do
          raise UnknownNetwork, network unless @backend.root?(network)

          @backend[network]
        end
      end

      #
      # Add a new network
      #
      def add_network(network)
        raise ArgumentError, 'network must be an IP address range' unless network.is_a?(IPAddr)

        @backend.transaction do
          raise NetworkAlreadyExists, network if @backend.root?(network)

          @backend[network] = []
        end
      end

      #
      # Add a peer to the given network
      #
      def add_peer(network, peer)
        @backend.transaction do
          raise UnknownNetwork, network unless @backend.root?(network)

          @backend[network] << peer
        end
      end

      #
      # Find the next address within the given network that is not assigned to a peer
      #
      def next_address(network)
        raise ArgumentError, 'network must be an IP address range' unless network.is_a?(IPAddr)

        peers(network).inject(network.succ) do |candidate, peer|
          candidate == peer.ip ? candidate.succ : peer.ip
        end
      end

      def servers(network)
        peers(network).select { |p| p.is_a?(Server) }
      end

      def clients(network)
        peers(network).select { |p| p.is_a?(Client) }
      end
    end
  end
end
