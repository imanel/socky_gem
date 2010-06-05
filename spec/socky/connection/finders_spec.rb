require 'spec/spec_helper'

describe Socky::Connection::Finders do
  include Socky::Connection::Finders
  
  context "class" do
    before(:each) do
      @connection1 = mock(:connection1, :client => "client1", :channels => [])
      @connection2 = mock(:connection2, :client => "client1", :channels => ["1", "3", "5"])
      @connection3 = mock(:connection3, :client => "client2", :channels => ["2", "5"])
      @connection4 = mock(:connection4, :client => "client3", :channels => ["3", "5"])
      @connections = [@connection1,@connection2,@connection3,@connection4]
      @connections.collect { |connection| Socky::Connection.connections << connection }
    end
    after(:each) do
      Socky::Connection.connections.clear
    end
    
    it "#find_all should return all connections" do
      self.class.find_all.should eql(@connections)
    end
    context "#find" do
      it "should return all connections if no options specified" do
        self.class.find.should eql(@connections)
      end
      context "if :clients option is specified" do
        it "should return all connections if :clients is nil or empty" do
          self.class.find(:clients => nil).should eql(@connections)
          self.class.find(:clients => []).should eql(@connections)
        end
        it "should return only connections from specified client" do
          self.class.find(:clients => "client1").should eql([@connection1,@connection2])
        end
        it "should return only connections from specified clients if array provided" do
          self.class.find(:clients => ["client1","client2"]).should eql([@connection1,@connection2,@connection3])
        end
      end
      context "if :channels option is specified" do
        it "should return all connections if :channels is nil or empty" do
          self.class.find(:channels => nil).should eql(@connections)
          self.class.find(:channels => []).should eql(@connections)
        end
        it "should return all connections that include specified channel" do
          self.class.find(:channels => "3").should eql([@connection2,@connection4])
        end
        it "should return all connections that include at last one of specified channels" do
          self.class.find(:channels => ["2","3"]).should eql([@connection2,@connection3,@connection4])
        end
      end
      context "if both :clients and :channels options are provided" do
        context "but :channels are empty" do
          it "should return only connections from specified client" do
            self.class.find(:channels => [],:clients => "client1").should eql([@connection1,@connection2])
          end
          it "should return only connections from specified clients if array provided" do
            self.class.find(:channels => [],:clients => ["client1","client2"]).should eql([@connection1,@connection2,@connection3])
          end
        end
        context "but :clients are empty" do
          it "should return all connections that include specified channel" do
            self.class.find(:clients => [],:channels => "3").should eql([@connection2,@connection4])
          end
          it "should return all connections that include at last one of specified channels" do
            self.class.find(:clients => [],:channels => ["2","3"]).should eql([@connection2,@connection3,@connection4])
          end
        end
        it "should return only connections from specified client that include specified channel" do
          self.class.find(:clients => "client1",:channels => "3").should eql([@connection2])
          self.class.find(:clients => "client1",:channels => "2").should eql([])
        end
        it "should return only connections from specified client that include one of specified channels" do
          self.class.find(:clients => "client1",:channels => ["2","3"]).should eql([@connection2])
        end
        it "should return only connections from specified clients that include specified channel" do
          self.class.find(:clients => ["client1","client2"],:channels => "2").should eql([@connection3])
        end
        it "should return only connections from specified clients that include at last one of specified channels" do
          self.class.find(:clients => ["client1","client2"],:channels => ["2","1"]).should eql([@connection2,@connection3])
        end
      end
    end
    it "#find_by_clients should call #find with clients option" do
      self.class.should_receive(:find).with({:clients => "client1"})
      self.class.find_by_clients("client1")
    end
    it "#find_by_channels should call #find with channels option" do
      self.class.should_receive(:find).with({:channels => "1"})
      self.class.find_by_channels("1")
    end
    it "#find_by_clients_and_channels should call #find with both clients and channels option" do
      self.class.should_receive(:find).with({:clients => "client1", :channels => "1"})
      self.class.find_by_clients_and_channels("client1","1")
    end
    
  end
end