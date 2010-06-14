module Socky
  class Runner
    include Socky::Misc

    class << self
      def run(argv = ARGV)
        server = self.new(argv)
        server.start
      end
    end

    def initialize(argv = ARGV)
      Options.prepare(argv)
    end

    def start
      EventMachine.epoll

      EventMachine.run do

        trap("TERM") { stop }
        trap("INT")  { stop }

        EventMachine::start_server("0.0.0.0", options[:port], EventMachine::WebSocket::Connection,
            :debug => options[:deep_debug], :secure => options[:secure]) do |ws|

          connection = Socky::Connection.new(ws)
          ws.onopen    { connection.subscribe }
          ws.onmessage { |msg| connection.process_message(msg) }
          ws.onclose   { connection.unsubscribe }

        end

        info ["Server started"]
      end
    end

    def stop
      info ["Server stopping"]
      EventMachine.stop
    end

  end
end