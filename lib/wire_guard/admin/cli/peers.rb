# frozen_string_literal: true

module WireGuard
  module Admin
    #
    # Commands for working with peers (servers and clients)
    #
    class Peers < Thor
      extend ClassHelpers
      include InstanceHelpers

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      desc 'list', 'Lists all peers'
      long_desc 'For a given network, lists all peers (servers and clients) in the configuration database.'
      method_option :network, desc: 'network', aliases: '-n', default: default_network
      def list
        if options[:verbose]
          warn "Using database #{repository.path}"
          warn "No clients in network #{network}." if repository.networks.empty?
        end
        repository.peers(network).each do |peer|
          if STDOUT.tty?
            puts peer
          else
            puts peer.name
          end
        end
      rescue StandardError
        warn "Error: #{$ERROR_INFO.message}"
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
