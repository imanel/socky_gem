require 'spec/spec_helper'

describe Socky::Message do
  before(:each) do
    @connection = mock(:connection, :name => "connection", :send_message => nil)
  end
  
  context "class" do
    context "#process" do
      before(:each) { @message = mock(:message, :process => nil) }
      it "should create new instance of self with provided params" do
        described_class.stub!(:new).and_return(@message)
        described_class.should_receive(:new).with(@connection, "test")
        described_class.process(@connection, "test")
      end
      it "should send #process to instance if valid message" do
        described_class.stub!(:new).and_return(@message)
        @message.should_receive(:process)
        described_class.process(@connection, "test")
      end
      it "should rescue from error if creating instance raise error" do
        described_class.stub!(:new).and_raise(Socky::SockyError)
        lambda{ described_class.process(@connection, "test") }.should_not raise_error
      end
      it "should rescue from error if parsing instance raise error" do
        @message.stub!(:process).and_raise(Socky::SockyError)
        described_class.stub!(:new).and_return(@message)
        lambda{ described_class.process(@connection, "test") }.should_not raise_error
      end
    end
    context "#new" do
      it "should create message with provided creator and message is message is JSON hash" do
        message = described_class.new(@connection, {:test => true}.to_json)
        message.params.should eql(:test => true)
        message.creator.should eql(@connection)
      end
      it "should raise error if message is not JSON" do
        lambda{described_class.new(@connection, {:test => true})}.should raise_error Socky::SockyError
        lambda{described_class.new(@connection, "test")}.should raise_error Socky::SockyError
      end
      it "should raise error if message is JSON but not JSON hash" do
        lambda{described_class.new(@connection, "test".to_json)}.should raise_error Socky::SockyError
      end
    end
  end
  
  context "instance" do
    before(:each) { @message = described_class.new(@connection, {}.to_json) }
    context "#process" do
      it "should call #broadcast if message command is :broadcast" do
        @message.stub!(:params).and_return({:command => :broadcast})
        @message.stub!(:broadcast)
        @message.should_receive(:broadcast)
        @message.process
      end
      it "should not distinguish between string and symbol in command" do
        @message.stub!(:params).and_return({:command => 'broadcast'})
        @message.stub!(:broadcast)
        @message.should_receive(:broadcast)
        @message.process
      end
      it "should call #query if message command is :query" do
        @message.stub!(:params).and_return({:command => :query})
        @message.stub!(:query)
        @message.should_receive(:query)
        @message.process
      end
      it "should raise error if message command is nil" do
        @message.stub!(:params).and_return({:command => nil})
        lambda {@message.process}.should raise_error Socky::SockyError
      end
      it "should raise error if message command is neither :broadcast nor :query" do
        @message.stub!(:params).and_return({:command => "invalid"})
        lambda {@message.process}.should raise_error Socky::SockyError
      end
    end
    context "#broadcast" do
      it "should call #broadcast_to_clients if message type is :to_clients" do
        @message.stub!(:params).and_return({:type => :to_clients})
        @message.stub!(:broadcast_to_clients)
        @message.should_receive(:broadcast_to_clients)
        @message.broadcast
      end
      it "should not distinguish between string and symbol in type" do
        @message.stub!(:params).and_return({:type => 'to_clients'})
        @message.stub!(:broadcast_to_clients)
        @message.should_receive(:broadcast_to_clients)
        @message.broadcast
      end
      it "should call #broadcast_to_channels if message type is :to_channels" do
        @message.stub!(:params).and_return({:type => :to_channels})
        @message.stub!(:broadcast_to_channels)
        @message.should_receive(:broadcast_to_channels)
        @message.broadcast
      end
      it "should call #broadcast_to_clients_on_channels if message type is :to_clients_on_channels" do
        @message.stub!(:params).and_return({:type => :to_clients_on_channels})
        @message.stub!(:broadcast_to_clients_on_channels)
        @message.should_receive(:broadcast_to_clients_on_channels)
        @message.broadcast
      end
      it "should raise error if message type is nil" do
        @message.stub!(:params).and_return({:type => nil})
        lambda {@message.broadcast}.should raise_error Socky::SockyError
      end
      it "should raise error if message type is not one of :to_clients, :to_channels or :to_cleints_on_channels" do
        @message.stub!(:params).and_return({:type => "invalid"})
        lambda {@message.broadcast}.should raise_error Socky::SockyError
      end
    end
    context "#broadcast_to_clients" do
      before(:each) do
        @message.stub!(:verify)
        Socky::Server.stub!(:send_to_clients)
      end
      it "should verify :clients params existence" do
        @message.should_receive(:verify).with(:clients)
        @message.broadcast_to_clients
      end
      it "should call socky server #send_to_clients with own params" do
        @message.stub!(:params).and_return(:body => "some message", :clients => "some clients")
        Socky::Server.should_receive(:send_to_clients).with("some message", "some clients")
        @message.broadcast_to_clients
      end
    end
    context "#broadcast_to_channels" do
      before(:each) do
        @message.stub!(:verify)
        Socky::Server.stub!(:send_to_channels)
      end
      it "should verify :channels params existence" do
        @message.should_receive(:verify).with(:channels)
        @message.broadcast_to_channels
      end
      it "should call socky server #send_to_channels with own params" do
        @message.stub!(:params).and_return(:body => "some message", :channels => "some channels")
        Socky::Server.should_receive(:send_to_channels).with("some message", "some channels")
        @message.broadcast_to_channels
      end
    end
    context "#broadcast_to_clients_on_channels" do
      before(:each) do
        @message.stub!(:verify)
        Socky::Server.stub!(:send_to_clients_on_channels)
      end
      it "should verify :clients params existence" do
        @message.should_receive(:verify).with(:clients)
        @message.broadcast_to_clients_on_channels
      end
      it "should verify :channels params existence" do
        @message.should_receive(:verify).with(:channels)
        @message.broadcast_to_clients_on_channels
      end
      it "should call socky server #send_to_clients_on_channels with own params" do
        @message.stub!(:params).and_return(:body => "some message", :clients => "some clients", :channels => "some channels")
        Socky::Server.should_receive(:send_to_clients_on_channels).with("some message", "some clients", "some channels")
        @message.broadcast_to_clients_on_channels
      end
    end
    context "#query" do
      it "should call #query_show_connections if message type is :show_connections" do
        @message.stub!(:params).and_return({:type => :show_connections})
        @message.stub!(:query_show_connections)
        @message.should_receive(:query_show_connections)
        @message.query
      end
      it "should not distinguish between string and symbol in type" do
        @message.stub!(:params).and_return({:type => 'show_connections'})
        @message.stub!(:query_show_connections)
        @message.should_receive(:query_show_connections)
        @message.query
      end
      it "should raise error if message type is nil" do
        @message.stub!(:params).and_return({:type => nil})
        lambda{ @message.query }.should raise_error Socky::SockyError
      end
      it "should raise error if message type is not :show_connections" do
        @message.stub!(:params).and_return({:type => "invalid"})
        lambda{ @message.query }.should raise_error Socky::SockyError
      end
    end
    context "#query_show_connections" do
      before(:each) do
        Socky::Connection.stub!(:find_all).and_return("find results")
        @message.stub!(:respond)
      end
      it "should ask for all connections" do
        Socky::Connection.should_receive(:find_all)
        @message.query_show_connections
      end
      it "should respond current connection list" do
        @message.should_receive(:respond).with("find results")
        @message.query_show_connections
      end
    end
    context "#verify" do
      it "should convert posted field to empty array if field is nil" do
        @message.params[:clients] = nil
        @message.verify :clients
        @message.params[:clients].should eql([])
      end
      it "should convert posted field to array containing field value if field is not array" do
        @message.params[:clients] = "some client"
        @message.verify :clients
        @message.params[:clients].should eql(["some client"])
      end
      it "should not convert field if field is array" do
        @message.params[:clients] = ["some client"]
        @message.verify :clients
        @message.params[:clients].should eql(["some client"])
      end
      it "should change every array value to string" do
        @message.params[:clients] = [1,2,3]
        @message.verify :clients
        @message.params[:clients].should eql(["1","2","3"])
      end
    end
    context "#respond" do
      it "should call creator #send_message" do
        @connection.should_receive(:send_message)
        @message.respond({:test => true})
      end
      it "should convert message to json" do
        @connection.should_receive(:send_message).with({:test => true}.to_json)
        @message.respond({:test => true})
      end
    end

  end
end