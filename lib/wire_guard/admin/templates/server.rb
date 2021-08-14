# frozen_string_literal: true

require 'erb'

module WireGuard
  module Admin
    module Templates
      #
      # Configuration template for a WireGuard::Admin::Server
      #
      class Server < ERB
        def self.template
          <<~SERVER_TEMPLATE
            # WireGuard configuration for <%= server.name %>
            # generated by wg-admin

            [Interface]
            Address = <%= server.ip %>/<%= network.prefix %>
            ListenPort = <%= server.port %>
            PrivateKey = <%= server.private_key %>
            # PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o <%= server.device %> -j MASQUERADE
            # PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o <%= server.device %> -j MASQUERADE
            <% clients.each do |client| %>
            [Peer]
            # Name = <%= client.name %>
            PublicKey = <%= client.public_key %>
            AllowedIPs = <%= client.ip %>/<%= client.ip.prefix %>
            <% end %>
          SERVER_TEMPLATE
        end

        attr_reader :server, :network, :clients

        def initialize(server:, network:, clients:)
          @server = server
          @network = network
          @clients = clients
          super(self.class.template)
        end

        def render
          result(binding)
        end
      end
    end
  end
end
