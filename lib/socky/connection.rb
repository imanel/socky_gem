require 'json'
require 'socky/connection/authentication'
require 'socky/connection/finders'

module Socky
  class Connection
    include Socky::Misc
    include Socky::Connection::Authentication
    include Socky::Connection::Finders

    attr_reader :socket

    class << self
      def connections
        @connections ||= []
      end
    end

    def initialize(socket)
      @socket = socket
    end

    def query
      socket.request["Query"] || {}
    end

    def admin
      ["true","1"].include?(query["admin"])
    end

    def client
      query["client_id"]
    end

    def secret
      query["client_secret"]
    end

    def channels
      @channels ||= query["channels"].to_s.split(",").collect(&:strip).reject(&:empty?)
      @channels[0] ||= nil # Every user should have at last one channel
      @channels
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
      if admin && authenticated?
        Socky::Message.process(self, msg)
      else
        self.send_message "You are not authorized to post messages"
      end
    end

    def send_message(msg)
      send_data({:type => :message, :body => msg})
    end

    def send_data(data)
      debug [self.name, "sending data", data.inspect]
      socket.send data.to_json
    end

    def disconnect
      socket.close_connection_after_writing
    end

    def connection_pool
      self.class.connections
    end

    def in_connection_pool?
      connection_pool.include?(self)
    end

    def add_to_pool
      connection_pool << self unless self.admin || in_connection_pool?
    end

    def remove_from_pool
      connection_pool.delete(self)
    end

    def to_json(options = {})
      {
        :id => self.object_id,
        :client_id => self.client,
        :channels => self.channels.reject{|channel| channel.nil?}
      }.to_json
    end

  end
end