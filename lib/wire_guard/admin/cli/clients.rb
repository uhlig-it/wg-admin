# frozen_string_literal: true

require 'thor'

module WireGuard
  module Admin
    #
    # Commands for working with clients
    #
    class Clients < Thor
      extend ClassHelpers
      include InstanceHelpers

      # rubocop:disable Metrics/AbcSize
      desc 'add NAME', 'Adds a new client with the given NAME'
      long_desc 'Adds a new client to the configuration database.'
      method_option :network, desc: 'network', aliases: '-n', default: default_network
      method_option :ip, desc: 'the IP address of the new client', aliases: '-i', required: false
      method_option :private_key, desc: 'The private key of the new client', aliases: '-P', required: false
      def add(name)
        warn "Using database #{repository.path}" if options[:verbose]
        client = Client.new(name: name, ip: ip)
        client.private_key = options[:private_key] if options[:private_key]
        repository.add_peer(network, client)
        if options[:verbose]
          warn 'New client was successfully added:'
          warn ''
          warn client
        end
      rescue StandardError => e
        raise Thor::Error, "Error: #{e.message}"
      end

      desc 'list', 'Lists all clients'
      long_desc 'For a given network, lists all clients in the configuration database.'
      method_option :network, desc: 'network', aliases: '-n', default: default_network
      def list
        if options[:verbose]
          warn "Using database #{repository.path}"
          warn "No clients in network #{network}." if repository.networks.empty?
        end
        repository.clients(network).each do |client|
          puts client
        end
      rescue StandardError => e
        raise Thor::Error, "Error: #{e.message}"
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
