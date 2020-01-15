# frozen_string_literal: true

require 'thor'

require 'wireguard/admin/repository'
require 'wireguard/admin/client'
require 'wireguard/admin/server'
require 'wireguard/admin/templates/client'

module Wireguard
  module Admin
    class CLI < Thor
      def self.exit_on_failure?
        true
      end

      class_option :verbose, type: :boolean, aliases: '-v'
      package_name 'wg-admin is an opinionated tool to administer Wireguard configuration.

Available'

      desc 'list-networks', 'Lists all known networks'
      long_desc "List the networks in the configuration database."
      def list_networks
        warn "Using database from #{repository.path}" if options[:verbose]
        repository.networks.each do |network|
          puts "  #{network}/#{network.prefix}"
        end
      end

      desc 'add-network NETWORK', 'Adds a new network'
      long_desc "Adds a new network to the configuration database."
      def add_network(network)
        warn "Using database from #{repository.path}" if options[:verbose]
        repository.add_network(network)
        warn "Network #{repository.network} was successfully added." if options[:verbose]
      rescue Repository::NetworkAlreadyExists
        warn "Error: #{$!.message}"
      end

      desc 'list-peers', 'Lists all peers'
      long_desc "For a given network, lists all peers in the configuration database."
      method_option :network, desc: 'network', aliases: '-n', default: ENV['WG_ADMIN_NETWORK']
      def list_peers
        warn "Using database from #{repository.path}" if options[:verbose]
        repository.peers(options[:network]).each do |peer|
          puts "  #{peer}"
        end
      rescue Repository::NetworkNotSpecified, Repository::UnknownNetwork
        warn "Error: #{$!.message}"
      end

      desc 'add-server NAME', 'Adds a new server with the given public DNS NAME'
      long_desc 'Adds a new server to the configuration database.'
      method_option :network, desc: 'network', aliases: '-n', default: ENV['WG_ADMIN_NETWORK']
      method_option :ip, desc: 'the (private) IP address of the new server (within the VPN)', aliases: '-i', required: false
      method_option :allowed_ips, desc: 'The range of allowed IP addresses that this server is routing', aliases: '-a', required: false
      method_option :device, desc: 'The network device used for forwarding traffic', aliases: '-d', required: false
      def add_server(name)
        warn "Using database from #{repository.path}" if options[:verbose]
        ip = options[:ip] || repository.next_address(options[:network])
        server = Server.new(name: name, ip: ip)
        server.allowed_ips = options[:allowed_ips] if options[:allowed_ips]
        server.device = options[:device] if options[:device]
        repository.add_peer(options[:network], server)
        if options[:verbose]
          warn "New server was successfully added:"
          warn ''
          warn server
        end
      rescue Repository::NetworkNotSpecified, Repository::UnknownNetwork
        warn "Error: #{$!.message}"
      end

      desc 'add-client NAME', 'Adds a new client with the given NAME'
      long_desc "Adds a new client to the configuration database."
      method_option :network, desc: 'network', aliases: '-n', default: ENV['WG_ADMIN_NETWORK']
      method_option :ip, desc: 'the IP address of the new client', aliases: '-i', required: false
      def add_client(name)
        warn "Using database from #{repository.path}" if options[:verbose]
        ip = options[:ip] || repository.next_address(options[:network])
        client = Client.new(name: name, ip: ip)
        repository.add_peer(options[:network], client)
        if options[:verbose]
          warn "New client was successfully added:"
          warn ''
          warn client
        end
      rescue Repository::NetworkNotSpecified, Repository::UnknownNetwork
        warn "Error: #{$!.message}"
      end

      desc 'config', 'Show the configuration of a peer'
      long_desc 'Prints the configuration for a peer to STDOUT.'
      method_option :network, desc: 'network', aliases: '-n', default: ENV['WG_ADMIN_NETWORK']
      def config(name)
        warn "Using database from #{repository.path}" if options[:verbose]
        peer = repository.find_peer(options[:network], name)
        servers = []
        puts Templates::Client.new(peer, servers).render
      rescue Repository::NetworkNotSpecified, Repository::UnknownNetwork
        warn "Error: #{$!.message}"
      end

      private

      def repository
        @repository ||= Repository.new(path)
      end

      def path
        ENV['WG_ADMIN_STORE'] || File.expand_path('~/.wg-admin.pstore')
      end
    end
  end
end
