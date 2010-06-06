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
        connection.send_message(error.message.to_json)
      end
    end

    def initialize(creator, message)
      @params = symbolize_keys(JSON.parse(message)) rescue raise(InvalidJSON, "invalid request")
      @creator = creator
    end

    def process
      debug [self.name, "processing", params.inspect]

      verify_secret!

      execute
    end

    def verify_secret!
      raise(UnauthorisedQuery, "invalid secret") unless options[:secret].nil? || options[:secret] == params[:secret]
    end

    def execute
      case params[:command].to_sym
        when :broadcast then broadcast
        when :query then query
        else raise(InvalidQuery, "unknown command")
      end
    rescue
      raise(InvalidQuery, "unknown command")
    end

    def broadcast
      case params[:type].to_sym
        when :to_clients then broadcast_to_clients
        when :to_channels then broadcast_to_channels
        when :to_clients_on_channels then broadcast_to_clients_on_channels
        else raise(InvalidQuery, "unknown broadcast type")
      end
    rescue
      raise(InvalidQuery, "unknown broadcast type")
    end

    def broadcast_to_clients
      verify :clients
      Socky::Server.send_to_clients(params[:body], params[:clients])
    end

    def broadcast_to_channels
      verify :channels
      Socky::Server.send_to_channels(params[:body], params[:channels])
    end

    def broadcast_to_clients_on_channels
      verify :clients
      verify :channels
      Socky::Server.send_to_clients_on_channels(params[:body], params[:clients], params[:channels])
    end

    def query
      case params[:type].to_sym
        when :show_connections then query_show_connections
        else raise(InvalidQuery, "unknown query type")
      end
    rescue
      raise(InvalidQuery, "unknown query type")
    end

    def query_show_connections
      respond Socky::Connection.find_all
    end

    def verify(field)
      params[field] = params[field].to_a unless params[field].is_a?(Array)
      params[field] = params[field].collect(&:to_s)
    end

    def respond(message)
      creator.send_message(message.to_json)
    end

  end
end