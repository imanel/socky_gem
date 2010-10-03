require 'json'

module Socky
  class Message
    include Socky::Misc

    class InvalidJSON < Socky::SockyError; end #:nodoc:
    class UnauthorisedQuery < Socky::SockyError; end #:nodoc:
    class InvalidQuery < Socky::SockyError; end #:nodoc:

    attr_reader :params, :creator

    class << self
      def process(connection, message)
        message = new(connection, message)
        message.process
      rescue SockyError => error
        error connection.name, error
        connection.send_message(error.message)
      end
    end

    def initialize(creator, message)
      @params = symbolize_keys(JSON.parse(message)) rescue raise(InvalidJSON, "invalid request")
      @creator = creator
    end

    def process
      debug [self.name, "processing", params.inspect]

      case params.delete(:command).to_s
        when "broadcast" then broadcast
        when "query" then query
        else raise(InvalidQuery, "unknown command")
      end
    end

    private

    def broadcast
      connections = Socky::Connection.find(params)
      send_message(params[:body], connections)
    end

    def query
      case params[:type].to_s
        when "show_connections" then query_show_connections
        else raise(InvalidQuery, "unknown query type")
      end
    end

    def query_show_connections
      respond Socky::Connection.find_all
    end

    def respond(message)
      creator.send_message(message)
    end

    def send_message(message, connections)
      connections.each{|connection| connection.send_message message}
    end

  end
end