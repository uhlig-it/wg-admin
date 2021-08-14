# frozen_string_literal: true

require 'thor'

module WireGuard
  module Admin
    #
    # Commands for working with servers
    #
    class Servers < Thor
      extend ClassHelpers
      include InstanceHelpers

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      desc 'add NAME', 'Adds a new server'
      long_desc 'Adds a new server with the given public DNS NAME to the configuration database.'
      method_option :network, desc: 'network', aliases: '-n', default: default_network
      method_option :ip, desc: 'the (private) IP address of the new server (within the VPN)', aliases: '-i', required: false
      method_option :port, desc: 'port to listen on', aliases: '-p', required: false
      method_option :allowed_ips, desc: 'The range of allowed IP addresses that this server is routing. Defaults to the network.', aliases: '-a', required: false
      method_option :device, desc: 'The network device used for forwarding traffic', aliases: '-d', required: false
      method_option :private_key, desc: 'The private key of the new server', aliases: '-P', required: false
      def add(name)
        warn "Using database #{repository.path}" if options[:verbose]
        server = Server.new(name: name, ip: ip, allowed_ips: options[:allowed_ips] || repository.find_network(network))
        server.device = options[:device] if options[:device]
        server.port = options[:port] if options[:port]
        server.private_key = options[:private_key] if options[:private_key]
        repository.add_peer(network, server)
        if options[:verbose]
          warn 'New server was successfully added:'
          warn ''
          warn server
        end
      rescue StandardError => e
        raise Thor::Error, "Error: #{e.message}"
      end

      desc 'remove NAME', 'Removes the server with the given NAME'
      long_desc 'Removes an existing server from the configuration database.'
      method_option :network, desc: 'network', aliases: '-n', default: default_network
      def remove(name)
        warn "Using database #{repository.path}" if options[:verbose]
        repository.remove_peer(network, name)
        warn 'Server was successfully removed.' if options[:verbose]
      rescue StandardError => e
        raise Thor::Error, "Error: #{e.message}"
      end

      desc 'list', 'Lists all servers'
      long_desc 'For a given network, lists all servers in the configuration database.'
      method_option :network, desc: 'network', aliases: '-n', default: default_network
      def list
        if options[:verbose]
          warn "Using database #{repository.path}"
          warn "No servers in network #{network}." if repository.networks.empty?
        end
        repository.servers(network).each do |server|
          puts server
        end
      rescue StandardError => e
        raise Thor::Error, "Error: #{e.message}"
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
    end
  end
end
