# frozen_string_literal: true

require 'thor'
require 'wire_guard/admin/cli/helpers'

module WireGuard
  module Admin
    #
    # Commands for working with networks
    #
    class Networks < Thor
      extend ClassHelpers
      include InstanceHelpers

      # rubocop:disable Metrics/AbcSize
      desc 'list', 'Lists all known networks'
      long_desc 'List the networks in the configuration database.'
      def list
        if options[:verbose]
          warn "Using database #{repository.path}"
          warn 'No networks defined.' if repository.networks.empty?
        end

        repository.networks.each do |network|
          puts "#{network}/#{network.prefix}"
        end
      rescue StandardError => e
        raise Thor::Error, "Error: #{e.message}"
      end
      # rubocop:enable Metrics/AbcSize

      desc 'add NETWORK', 'Adds a new network'
      long_desc 'Adds a new network to the configuration database.'
      def add(network)
        warn "Using database #{repository.path}" if options[:verbose]
        nw = IPAddr.new(network)
        repository.add_network(nw)
        warn "Network #{nw}/#{nw.prefix} was successfully added." if options[:verbose]
      rescue Repository::NetworkAlreadyExists => e
        raise Thor::Error, "Error: #{e.message}"
      end
    end
  end
end
