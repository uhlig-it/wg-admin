require 'pstore'
require 'ipaddr'

module Wireguard
  module Admin
    class Repository
      class NotInitializedError < StandardError
        def initialize
          super('wg-admin was not properly initialized')
        end
      end

      attr_reader :path

      def initialize(path)
        @path = path
      end

      def network
        backend.transaction do
          tree[:network].tap do |result|
            raise NotInitializedError unless result
          end
        end
      end

      def network=(nw)
        backend.transaction do
          if nw.is_a?(IPAddr)
            tree[:network] = nw
          else
            tree[:network] = IPAddr.new(nw)
          end
        end
      end

      def peers
        backend.transaction do
          tree[:peers] = Array.new unless tree[:peers]
          tree[:peers]
        end
      end

      def add_peer(peer)
        backend.transaction do
          tree[:peers] = Array.new unless tree[:peers]
          tree[:peers] << peer
        end
      end

      def next_ip_address
        peers.inject(network.succ) do |candidate, peer|
          candidate == peer.ip ? candidate.succ : peer.ip
        end
      end

      private

      def backend
        @backend ||= PStore.new(@path)
      end

      def tree(namespace = 'default')
        backend[namespace] = Hash.new unless backend[namespace]
        backend[namespace]
      end
    end
  end
end
