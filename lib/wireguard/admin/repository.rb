require 'pstore'

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
          tree[:network]
        end
      end

      def network=(nw)
        backend.transaction do
          tree[:network] = nw
        end
      end

      def peers
        []
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
