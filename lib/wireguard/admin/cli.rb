# frozen_string_literal: true

require 'thor'

require 'wireguard/admin/repository'
require 'wireguard/admin/client'
require 'wireguard/admin/server'

module Wireguard
  module Admin
    class CLI < Thor
      def self.exit_on_failure?
        true
      end

      class_option :verbose, type: :boolean, aliases: '-v'
      package_name 'wg-admin is an opinionated tool to administer Wireguard configuration.

Available'

      desc 'init', 'Adds a new server'
      long_desc "Initializes the configuration database with a new network."
      method_option :network,
        desc: 'network range',
        aliases: '-n',
        default: '10.0.0.0/8'
      def init
        warn "Using #{repository.path}" if options[:verbose]
        repository.network = options[:network]
        warn "Network #{options[:network]} was successfully created." if options[:verbose]
      end

      desc 'list', 'Lists the network and peers'
      long_desc "List the network and all peers in the configuration database."
      def list
        warn "Using #{repository.path}" if options[:verbose]
        puts "Network: #{repository.network}/#{repository.network.prefix}"
        puts
        puts "Peers:"
        repository.peers.each do |peer|
          puts "  #{peer}"
        end
      rescue Repository::NotInitializedError
        warn "Error: #{$!.message}. Run wg-admin init to fix this."
      end

      desc 'add-server', 'Adds a new server'
      long_desc "Adds a new server to the configuration database."
      method_option :name,
        desc: 'the public DNS name of the new server',
        aliases: '-n',
        required: true
      method_option :ip,
        desc: 'the (private) IP address of the new server (within the VPN)',
        aliases: '-i',
        required: false
      method_option :allowed_ips,
        desc: 'The range of allowed IP addresses that this server is routing',
        aliases: '-a',
        required: false
      method_option :device,
        desc: 'The network device used for forwarding traffic',
        aliases: '-d',
        required: false
      def add_server
        warn "Using #{repository.path}" if options[:verbose]
        ip = options[:ip] || repository.next_ip_address
        server = Server.new(name: options[:name], ip: ip)
        server.allowed_ips = options[:allowed_ips] if options[:allowed_ips]
        server.device = options[:device] if options[:device]
        repository.add_peer(server)
        if options[:verbose]
          warn "New server was successfully added:"
          warn ''
          warn server
        end
      rescue Repository::NotInitializedError
        warn "Error: #{$!.message}. Run wg-admin init to fix this."
      end

      desc 'add-client', 'Adds a new client'
      long_desc "Adds a new client to the configuration database."
      method_option :name,
        desc: 'the administrative name of the new client',
        aliases: '-n',
        required: true
      method_option :ip,
        desc: 'the IP address of the new client',
        aliases: '-i',
        required: false
      def add_client
        warn "Using #{repository.path}" if options[:verbose]
        ip = options[:ip] || repository.next_ip_address
        client = Client.new(name: options[:name], ip: ip)
        repository.add_peer(client)
        if options[:verbose]
          warn "New client was successfully added:"
          warn ''
          warn client
        end
      rescue Repository::NotInitializedError
        warn "Error: #{$!.message}. Run wg-admin init to fix this."
      end

      private

      def repository
        @repository ||= Repository.new(ENV['WG_ADMIN_STORE'] || File.expand_path('~/.wg-admin.pstore'))
      end
    end
  end
end
