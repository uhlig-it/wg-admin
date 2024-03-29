# frozen_string_literal: true

require 'erb'

module WireGuard
  module Admin
    module Templates
      #
      # Configuration template for a WireGuard::Admin::Client
      #
      class Client < ERB
        def self.template
          <<~CLIENT_TEMPLATE
            # WireGuard configuration for <%= client.name %>
            # generated by wg-admin

            [Interface]
            PrivateKey = <%= client.private_key %>
            Address = <%= client.ip %>/<%= network.prefix %>
            <% servers.each do |server| %>

            [Peer]
            PublicKey = <%= server.public_key %>
            EndPoint = <%= server.name %>:<%= server.port %>
            AllowedIPs = <%= server.allowed_ips %>/<%= server.allowed_ips.prefix %>
            PersistentKeepalive = 25
            <% end %>
          CLIENT_TEMPLATE
        end

        attr_reader :client, :network, :servers

        def initialize(client:, network:, servers:)
          @client = client
          @network = network
          @servers = servers
          super(self.class.template, trim_mode: '<>')
        end

        def render
          result(binding)
        end
      end
    end
  end
end
