# frozen_string_literal: true

require 'thor'
require 'ipaddr'

require 'wireguard/admin/repository'
require 'wireguard/admin/client'
require 'wireguard/admin/server'
require 'wireguard/admin/templates/client'
require 'wireguard/admin/templates/server'

module Wireguard
  module Admin
    class CLI < Thor
      class << self
        def exit_on_failure?
          true
        end

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

      class_option :verbose, type: :boolean, aliases: '-v'
      package_name 'wg-admin is an opinionated tool to administer Wireguard configuration.

Available'

      desc 'list-networks', 'Lists all known networks'
      long_desc 'List the networks in the configuration database.'
      def list_networks
        warn "Using database from #{repository.path}" if options[:verbose]
        repository.networks.each do |network|
          puts "  #{network}/#{network.prefix}"
        end
      end

      desc 'add-network NETWORK', 'Adds a new network'
      long_desc 'Adds a new network to the configuration database.'
      def add_network(network)
        warn "Using database from #{repository.path}" if options[:verbose]
        repository.add_network(IPAddr.new(network))
        warn "Network #{repository.network} was successfully added." if options[:verbose]
      rescue Repository::NetworkAlreadyExists
        warn "Error: #{$!.message}"
      end

      desc 'list-peers', 'Lists all peers'
      long_desc 'For a given network, lists all peers in the configuration database.'
      method_option :network, desc: 'network', aliases: '-n', default: default_network
      def list_peers
        warn "Using database from #{repository.path}" if options[:verbose]
        repository.peers(IPAddr.new(options[:network])).each do |peer|
          puts "  #{peer}"
        end
      rescue
        warn "Error: #{$!.message}"
      end

      desc 'add-server NAME', 'Adds a new server with the given public DNS NAME'
      long_desc 'Adds a new server to the configuration database.'
      method_option :network, desc: 'network', aliases: '-n', default: default_network
      method_option :ip, desc: 'the (private) IP address of the new server (within the VPN)', aliases: '-i', required: false
      method_option :allowed_ips, desc: 'The range of allowed IP addresses that this server is routing', aliases: '-a', required: false
      method_option :device, desc: 'The network device used for forwarding traffic', aliases: '-d', required: false
      def add_server(name)
        warn "Using database from #{repository.path}" if options[:verbose]
        network = IPAddr.new(options[:network])
        server = Server.new(name: name, ip: ip, allowed_ips: options[:allowed_ips] || repository.find_network(network))
        server.device = options[:device] if options[:device]
        repository.add_peer(network, server)
        if options[:verbose]
          warn 'New server was successfully added:'
          warn ''
          warn server
        end
      rescue
        warn "Error: #{$!.message}"
      end

      desc 'add-client NAME', 'Adds a new client with the given NAME'
      long_desc 'Adds a new client to the configuration database.'
      method_option :network, desc: 'network', aliases: '-n', default: default_network
      method_option :ip, desc: 'the IP address of the new client', aliases: '-i', required: false
      def add_client(name)
        warn "Using database from #{repository.path}" if options[:verbose]
        network = IPAddr.new(options[:network])
        client = Client.new(name: name, ip: ip)
        repository.add_peer(network, client)
        if options[:verbose]
          warn 'New client was successfully added:'
          warn ''
          warn client
        end
      rescue
        warn "Error: #{$!.message}"
      end

      desc 'config', 'Show the configuration of a peer'
      long_desc 'Prints the configuration for a peer to STDOUT.'
      method_option :network, desc: 'network', aliases: '-n', default: default_network
      def config(name)
        warn "Using database from #{repository.path}" if options[:verbose]
        network = IPAddr.new(options[:network])
        peer = repository.find_peer(network, name)

        case peer
        when Server
          puts Templates::Server.new(peer, repository.clients(network)).render
        when Client
          puts Templates::Client.new(peer, repository.servers(network)).render
        else
          raise "No template defined for #{peer}"
        end
      rescue
        warn "Error: #{$!.message}"
      end

      private

      def repository
        self.class.repository
      end

      def ip
        if options[:ip]
          IPAddr.new(options[:ip])
        else
          repository.next_address(IPAddr.new(options[:network]))
        end
      end
    end
  end
end
