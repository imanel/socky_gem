require 'spec/spec_helper'

describe EM::WebSocket::Connection do

  it "should not receive debug message if :debug option is false" do
    Socky.logger.stub!(:debug)
    Socky.logger.should_not_receive(:debug)
    EM.run do
      EM.add_timer(0.1) do
        http = EventMachine::HttpRequest.new('ws://127.0.0.1:9999/').get(:timeout => 0)
        http.errback  { http.close_connection }
        http.callback { http.close_connection }
      end

      EM::WebSocket.start(:host => "127.0.0.1", :port => 9999, :debug => false) do |ws|
        ws.onclose { EM.stop }
      end
    end
  end

  it "should use Socky.logger.debug instead of pp when instance call #debug" do
    Socky.logger.stub!(:debug)
    Socky.logger.should_receive(:debug).with("Socket initialize")
    EM.run do
      EM.add_timer(0.1) do
        http = EventMachine::HttpRequest.new('ws://127.0.0.1:9999/').get(:timeout => 0)
        http.errback  { http.close_connection }
        http.callback { http.close_connection }
      end

      EM::WebSocket.start(:host => "127.0.0.1", :port => 9999, :debug => true) do |ws|
        ws.onclose { EM.stop }
      end
    end
  end

end