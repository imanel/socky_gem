module Socky
  class Runner
    include Socky::Misc

    class << self
      def run(argv = ARGV)
        server = self.new(argv)

        if options[:kill]
          server.kill_pid
        elsif options[:daemonize]
          server.daemonize
        else
          server.start
        end
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
            :debug => options[:deep_debug], :secure => options[:secure], :tls_options => options[:tls_options]) do |ws|

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

    def store_pid(pid)
     FileUtils.mkdir_p(File.dirname(pid_path))
     File.open(pid_path, 'w'){|f| f.write("#{pid}\n")}
    rescue => e
      puts e
      exit
    end

    def daemonize
      fork do
         Process.setsid
         exit if fork
         store_pid(Process.pid)
         # Dir.chdir "/" # Mucks up logs
         File.umask 0000
         STDIN.reopen "/dev/null"
         STDOUT.reopen "/dev/null", "a"
         STDERR.reopen STDOUT
         start
       end
    end

    def kill_pid
      begin
        pid = IO.read(pid_path).chomp.to_i
        FileUtils.rm pid_path
        Process.kill(9, pid)
        puts "killed PID: #{pid}"
      rescue => e
        puts e
      end
      exit
    end
  end
end