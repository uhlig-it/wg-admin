require 'erb'

module Wireguard
  module Admin
    module Templates
      class Server < ERB
        def self.template
          <<~EOT
            [Interface]
            Address = <%= server.ip %>/24
            ListenPort = <%= server.port %>
            PrivateKey = <%= server.private_key %>
            # PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o <%= server.device %> -j MASQUERADE
            # PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o <%= server.device %> -j MASQUERADE

            <% clients.each do |client| %>
            [Peer]
            # Name = <%= client.name %>
            PublicKey = <%= client.public_key %>
            AllowedIPs = <%= client.ip %>/32
            <% end %>
          EOT
        end

        attr_reader :server, :clients

        def initialize(server, clients)
          @server = server
          @clients = clients
          @template = self.class.template
          super(@template)
        end

        def render
          result(binding)
        end
      end
    end
  end
end
