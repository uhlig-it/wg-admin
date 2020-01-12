# frozen_string_literal: true
require 'thor'

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
      long_desc <<-LONGDESC
      This command adds a new server to the configuration database.
      LONGDESC
      method_option :name,
        desc: 'the DNS name of new the Wireguard bounce server',
        aliases: '-n',
        required: true
      def init
        warn "Creating server #{options[:name]}" if options[:verbose]
      end
    end
  end
end
