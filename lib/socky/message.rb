require 'json'

module Socky
  class Message
    include Socky::Misc

    class UnauthorisedQuery < Socky::SockyError #:nodoc:
    end

    class InvalidBroadcast < Socky::SockyError #:nodoc:
    end

    class InvalidQuery < Socky::SockyError #:nodoc:
    end

    attr_reader :params, :creator

    class << self
      def process(connection, message)
        m = new(connection, message)
        m.process
      rescue SockyError => e
        error connection.name, e
        m.respond e.message
      end
    end

    def initialize(creator, message)
      @params = symbolize_keys JSON.parse(message)
      @creator = creator
    end

    def process
      debug [self.name, "processing", params.inspect]

      verify_secret!

      case params[:command].to_sym
        when :broadcast then broadcast
        when :query then query
      end
    end

    def verify_secret!
      raise(UnauthorisedQuery, "invalid secret") unless options[:secret].nil? || options[:secret] == params[:secret]
    end

    def broadcast
      case params[:type].to_sym
        when :to_clients then broadcast_to_clients
        when :to_channels then broadcast_to_channels
        when :to_clients_on_channels then broadcast_to_clients_on_channels
        else raise InvalidQuery, "unknown broadcast type"
      end
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
        else raise InvalidQuery, "unknown query type"
      end
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