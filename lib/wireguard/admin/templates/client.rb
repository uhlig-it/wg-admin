require 'erb'

module Wireguard
  module Admin
    module Templates
      class Client < ERB
        def self.template
          <<~EOT
            [Interface]
            PrivateKey = <%= client.private_key %>
            Address = <%= client.ip %>/24

            <% servers.each do |server| %>
            [Peer]
            PublicKey = <%= server.public_key %>
            EndPoint = <%= server.name %>:<%= server.port %>
            AllowedIPs = <%= server.allowed_ips %>
            PersistentKeepalive = 25
            <% end %>
          EOT
        end

        attr_reader :client, :servers

        def initialize(client, servers)
          @client = client
          @servers = servers
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
