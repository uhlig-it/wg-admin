# frozen_string_literal: true

require 'thor'
require 'ipaddr'

require 'wire_guard/admin/repository'
require 'wire_guard/admin/client'
require 'wire_guard/admin/server'
require 'wire_guard/admin/templates/client'
require 'wire_guard/admin/templates/server'

require 'wire_guard/admin/cli/helpers'
require 'wire_guard/admin/cli/networks'
require 'wire_guard/admin/cli/clients'
require 'wire_guard/admin/cli/servers'
require 'wire_guard/admin/cli/peers'

module WireGuard
  module Admin
    #
    # Provides all the commands
    #
    class CLI < Thor
      extend ClassHelpers
      include InstanceHelpers

      def self.exit_on_failure?
        true
      end

      class_option :verbose, type: :boolean, aliases: '-v'
      package_name 'wg-admin is an opinionated tool to administer WireGuard configuration.

Available'

      desc 'networks SUBCOMMAND ...ARGS', 'work with networks'
      subcommand 'networks', Networks

      desc 'clients SUBCOMMAND ...ARGS', 'work with clients'
      subcommand 'clients', Clients

      desc 'servers SUBCOMMAND ...ARGS', 'work with servers'
      subcommand 'servers', Servers

      desc 'peers SUBCOMMAND ...ARGS', 'work with peers'
      subcommand 'peers', Peers

      # rubocop:disable  Metrics/MethodLength, Metrics/AbcSize
      desc 'config PEER', 'Show the configuration of a peer'
      long_desc 'Prints the configuration for a peer to STDOUT.'
      method_option :network, desc: 'network', aliases: '-n', default: default_network
      def config(name)
        warn "Using database #{repository.path}" if options[:verbose]
        peer = repository.find_peer(network, name)

        case peer
        when Server
          puts Templates::Server.new(peer, repository.clients(network)).render
        when Client
          puts Templates::Client.new(peer, repository.servers(network)).render
        else
          raise "No template defined for #{peer}"
        end
      rescue StandardError
        warn "Error: #{$ERROR_INFO.message}"
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
    end
  end
end
