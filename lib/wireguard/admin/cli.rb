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

      desc 'init', 'Adds a new server with the given NAME'
      long_desc "Adds a new server to the configuration database."
      method_option :network,
        desc: 'the DNS name of the new server',
        aliases: '-n',
        default: '10.0.0.0/8'
      def init
        warn "Using #{repository.path}" if options[:verbose]
        repository.network = options[:network]
        warn "Metwork #{options[:network]} was successfully created." if options[:verbose]
      end

      desc 'list', 'Lists the network and peers'
      def list
        warn "Using #{repository.path}" if options[:verbose]
        puts "Network: #{repository.network}"

        puts

        puts "Peers:"
        repository.peers.each do |peer|
          puts peer
        end
      end

      private

      def repository
        @repository ||= Repository.new(ENV['WG_ADMIN_STORE'] || File.expand_path('~/.wg-admin.pstore'))
      end
    end
  end
end
