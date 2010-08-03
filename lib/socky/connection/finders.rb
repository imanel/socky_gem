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
          to = symbolize_keys(opts[:to]) || {}
          exclude = symbolize_keys(opts[:except]) || {}

          connections = find_all
          connections = filter_by_clients(connections, to[:clients], exclude[:clients])
          connections = filter_by_channels(connections, to[:channels], exclude[:channels])

          connections
        end

        private

        def filter_by_clients(connections, included_clients = nil, excluded_clients = nil)
          # Empty table means "no users" - nil means "all users"
          return [] if (included_clients.is_a?(Array) && included_clients.empty?)

          included_clients = included_clients.to_a
          excluded_clients = excluded_clients.to_a

          connections.collect do |connection|
            connection if (included_clients.empty? || included_clients.include?(connection.client)) && !excluded_clients.include?(connection.client)
          end.compact
        end

        def filter_by_channels(connections, included_channels = nil, excluded_channels = nil)
          # Empty table means "no channels" - nil means "all channels"
          return [] if (included_channels.is_a?(Array) && included_channels.empty?)

          included_channels = included_channels.to_a
          excluded_channels = excluded_channels.to_a

          connections.collect do |connection|
            connection if connection.channels.any? do |channel|
              (included_channels.empty? || included_channels.include?(channel) ) && !excluded_channels.include?(channel)
            end
          end.compact
        end

      end

    end
  end
end