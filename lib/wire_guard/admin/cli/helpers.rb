# frozen_string_literal: true

module WireGuard
  module Admin
    #
    # Shared class methods
    #
    module ClassHelpers
      def default_network
        ENV['WG_ADMIN_NETWORK']
      end

      def path
        ENV['WG_ADMIN_STORE'] || File.expand_path('~/.wg-admin.pstore')
      end

      def repository
        @repository ||= Repository.new(path)
      end
    end

    #
    # Shared instance methods
    #
    module InstanceHelpers
      def repository
        self.class.repository
      end

      def ip
        if options[:ip]
          IPAddr.new(options[:ip])
        else
          repository.next_address(network)
        end
      end

      def network
        IPAddr.new(options[:network])
      end
    end
  end
end
