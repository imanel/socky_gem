require 'spec/spec_helper'

describe Socky::Server do
  
  context "class" do
    it "#send_data should call send_message on each of provided connections" do
      connections = []
      3.times {|i| connections << mock("connection#{i}", :send_message => nil)}
      connections.each{|connection| connection.should_receive(:send_message).with("abstract")}
      described_class.send_data("abstract",connections)
    end
    it "#send_to_clients should find connections by clients and call #send_data on them" do
      Socky::Connection.stub!(:find_by_clients).and_return(["first","second","third"])
      described_class.stub!(:send_data)
      Socky::Connection.should_receive(:find_by_clients).with("abstract")
      described_class.should_receive(:send_data).with("message", ["first","second","third"])
      described_class.send_to_clients("message","abstract")
    end
    it "#send_to_channels should find connections by channels and call #send_data on them" do
      Socky::Connection.stub!(:find_by_channels).and_return(["first","second","third"])
      described_class.stub!(:send_data)
      Socky::Connection.should_receive(:find_by_channels).with("abstract")
      described_class.should_receive(:send_data).with("message", ["first","second","third"])
      described_class.send_to_channels("message","abstract")
    end
    it "#send_to_clients_on_channels should find connections by clients and channels and call #send_data on them" do
      Socky::Connection.stub!(:find_by_clients_and_channels).and_return(["first","second","third"])
      described_class.stub!(:send_data)
      Socky::Connection.should_receive(:find_by_clients_and_channels).with("abstract1","abstract2")
      described_class.should_receive(:send_data).with("message", ["first","second","third"])
      described_class.send_to_clients_on_channels("message","abstract1","abstract2")
    end
  end
  
end