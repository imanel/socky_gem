module Socky
  class Connection
    module Finders

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def find_all
          Socky::Connection.connections
        end

        def find(opts = {})
          clients = opts[:clients].to_a
          channels = opts[:channels].to_a
          connections = find_all
          connections = filter_by_clients(connections, clients) unless clients.empty?
          connections = filter_by_channels(connections, channels) unless channels.empty?

          connections
        end

        def find_by_clients(clients)
          find(:clients => clients)
        end

        def find_by_channels(channels)
          find(:channels => channels)
        end

        def find_by_clients_and_channels(clients, channels)
          find(:clients => clients, :channels => channels)
        end

        private

        def filter_by_clients(connections, clients)
          connections.collect{ |con| con if clients.include? con.client }.compact
        end

        def filter_by_channels(connections, channels)
          connections.collect{ |con| con if channels.any?{ |chan| con.channels.include?(chan) } }.compact
        end

      end

    end
  end
end