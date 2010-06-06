module Socky
  class Server
    include Socky::Misc

    class << self

      def send_to_clients(message, clients)
        connections = Socky::Connection.find_by_clients(clients)
        send_data(message, connections)
      end

      def send_to_channels(message, channels)
        connections = Socky::Connection.find_by_channels(channels)
        send_data(message, connections)
      end

      def send_to_clients_on_channels(message, clients, channels)
        connections = Socky::Connection.find_by_clients_and_channels(clients, channels)
        send_data(message, connections)
      end

      def send_data(message, connections)
        connections.each{|connection| connection.send_message message}
      end

    end
  end
end