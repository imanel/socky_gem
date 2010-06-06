require 'spec/spec_helper'

describe Socky::Runner do
  
  context "#class" do
    context "#run" do
      before(:each) do
        @server = mock(:server, :start => nil)
        described_class.stub!(:new).and_return(@server)
      end
      it "should create new instance of self" do
        described_class.should_receive(:new).with("some args")
        described_class.run("some args")
      end
      it "should call #start on new instance of self" do
        @server.should_receive(:start)
        described_class.run
      end
    end
    context "#new" do
      it "should prepare options from args" do
        Socky::Options.stub!(:prepare)
        Socky::Options.should_receive(:prepare).with("some args")
        described_class.new("some args")
      end
    end
  end
  
  context "#instance" do
    before(:each) do
      Socky::Options.stub!(:prepare)
      @runner = described_class.new
    end
    
    context "#start" do
      it "should create valid websocket server" do
        begin
          EM.run do
            MSG = "Hello World!"
            EventMachine.add_timer(0.1) do
              http = EventMachine::HttpRequest.new('ws://127.0.0.1:12345/').get :timeout => 0
              http.errback {
                EM.stop
                fail
              }
              http.callback {
                http.response_header.status.should == 101
                EM.stop
              }
            end
          
            Socky.stub!(:options).and_return({:port => 12345})
            Socky.logger = mock(:logger, :info => nil, :debug => nil)
            @runner.start
          end
        ensure
          Socky.logger = nil
        end
      end
    end
    
  end
end