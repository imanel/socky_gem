require 'socky/connection/authentication'
require 'socky/connection/finders'

module Socky
  class Connection
    include Socky::Misc
    include Socky::Connection::Authentication
    include Socky::Connection::Finders

    @@connections = []

    attr_reader :socket

    class << self
      def connections
        @@connections
      end
    end

    def initialize(socket)
      @socket = socket
    end

    def admin
      socket.request["Query"]["admin"] == "1"
    end

    def client
      socket.request["Query"]["client_id"]
    end

    def secret
      socket.request["Query"]["client_secret"]
    end

    def channels
      @channels ||= socket.request["Query"]["channels"].to_s.split(",").collect(&:strip).reject(&:empty?)
    end

    def subscribe
      debug [self.name, "incoming"]
      subscribe_request
    end

    def unsubscribe
      debug [self.name, "terminated"]
      unsubscribe_request
    end

    def process_message(msg)
      if admin
        Socky::Message.process(self, msg)
      else
        self.send_message "You are not authorized to post messages"
      end
    end

    def send_message(msg)
      debug [self.name, "sending message", msg.inspect]
      socket.send msg
    end

    def disconnect
      socket.close_connection_after_writing
    end

    def add_to_pool
      @@connections << self unless self.admin || @@connections.include?(self)
    end

    def remove_from_pool
      @@connections.delete(self)
    end

    def to_json
      {
        :id => self.object_id,
        :client_id => self.client,
        :channels => self.channels
      }.to_json
    end

  end
end