# frozen_string_literal: true

require 'thor'
require 'wireguard/admin/repository'

module Wireguard
  module Admin
    class CLI < Thor
      def self.exit_on_failure?
        true
      end

      package_name 'wg-admin is an opinionated tool to administer Wireguard configuration.

Available'
      class_option :verbose, type: :boolean, aliases: '-v'

      desc 'init', 'Adds a new server'
      long_desc "Initializes the configuration database with a new network."
      method_option :network,
        desc: 'the DNS name of the new server',
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
          puts "\t#{peer}"
        end
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
        result = repository.add_client(name: options[:name], ip: options[:ip])
        warn "New client #{result} was successfully added." if options[:verbose]
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
