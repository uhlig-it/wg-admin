require 'pstore'
require 'ipaddr'

module Wireguard
  module Admin
    class Repository
      class NetworkNotSpecified < StandardError
        def initialize
           super("Network not specified")
        end
      end

      class UnknownNetwork < StandardError
        def initialize(unknown)
          super("Network #{unknown} is unknown")
        end
      end

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

      def networks
        @backend.transaction do
          @backend.roots
        end
      end

      def peers(nw)
        network = network(nw)

        @backend.transaction do
          raise UnknownNetwork.new(network) unless @backend.root?(network)
          @backend[network]
        end
      end

      def add_network(nw)
        network = network(nw)
        @backend.transaction do
          raise NetworkAlreadyExists.new(network) if @backend.root?(network)
          @backend[network] = Array.new
        end
      end

      def add_peer(nw, peer)
        network = network(nw)

        @backend.transaction do
          raise UnknownNetwork.new(network) unless @backend.root?(network)
          @backend[network] << peer
        end
      end

      # Find the next address within the given network that is not assigned to a peer
      def next_address(nw)
        network = network(nw)

        peers(network).inject(network.succ) do |candidate, peer|
          candidate == peer.ip ? candidate.succ : peer.ip
        end
      end

      private

      def network(nw)
        raise NetworkNotSpecified unless nw

        if nw.is_a?(IPAddr)
          nw
        else
          IPAddr.new(nw)
        end
      end
    end
  end
end
