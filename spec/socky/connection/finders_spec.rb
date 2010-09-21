require 'spec_helper'

describe Socky::Connection::Finders do
  include Socky::Connection::Finders
  include Socky::Misc
  
  context "class" do
    before(:each) do
      @connection1 = mock(:connection1, :client => "client1", :channels => [nil])
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
      context "on :to" do
        context "if :clients option is specified" do
          it "should return all connections if :clients is nil" do
            self.class.find(:to => {:clients => nil}).should eql(@connections)
          end
          it "should return none connections if :clients is empty" do
            self.class.find(:to => {:clients => []}).should eql([])
          end
          it "should return only connections from specified client" do
            self.class.find(:to => {:clients => "client1"}).should eql([@connection1,@connection2])
          end
          it "should return only connections from specified clients if array provided" do
            self.class.find(:to => {:clients => ["client1","client2"]}).should eql([@connection1,@connection2,@connection3])
          end
        end
        context "if :channels option is specified" do
          it "should return all connections if :channels is nil" do
            self.class.find(:to => {:channels => nil}).should eql(@connections)
          end
          it "should return none connections if :channels is empty" do
            self.class.find(:to => {:channels => []}).should eql([])
          end
          it "should return all connections that include specified channel" do
            self.class.find(:to => {:channels => "3"}).should eql([@connection2,@connection4])
          end
          it "should return all connections that include at last one of specified channels" do
            self.class.find(:to => {:channels => ["2","3"]}).should eql([@connection2,@connection3,@connection4])
          end
        end
        context "if both :clients and :channels options are provided" do
          context "but :channels are nil" do
            it "should return only connections from specified client" do
              self.class.find(:to => {:channels => nil,:clients => "client1"}).should eql([@connection1,@connection2])
            end
            it "should return only connections from specified clients if array provided" do
              self.class.find(:to => {:channels => nil,:clients => ["client1","client2"]}).should eql([@connection1,@connection2,@connection3])
            end
          end
          context "but :channels are empty" do
            it "should return none connections" do
              self.class.find(:to => {:channels => [],:clients => "client1"}).should eql([])
            end
            it "should return none connections if array provided" do
              self.class.find(:to => {:channels => [],:clients => ["client1","client2"]}).should eql([])
            end
          end
          context "but :clients are nil" do
            it "should return all connections that include specified channel" do
              self.class.find(:to => {:clients => nil,:channels => "3"}).should eql([@connection2,@connection4])
            end
            it "should return all connections that include at last one of specified channels" do
              self.class.find(:to => {:clients => nil,:channels => ["2","3"]}).should eql([@connection2,@connection3,@connection4])
            end
          end
          context "but :clients are empty" do
            it "should return none connections" do
              self.class.find(:to => {:clients => [],:channels => "3"}).should eql([])
            end
            it "should return none connections if array provided" do
              self.class.find(:to => {:clients => [],:channels => ["2","3"]}).should eql([])
            end
          end
          it "should return only connections from specified client that include specified channel" do
            self.class.find(:to => {:clients => "client1",:channels => "3"}).should eql([@connection2])
            self.class.find(:to => {:clients => "client1",:channels => "2"}).should eql([])
          end
          it "should return only connections from specified client that include one of specified channels" do
            self.class.find(:to => {:clients => "client1",:channels => ["2","3"]}).should eql([@connection2])
          end
          it "should return only connections from specified clients that include specified channel" do
            self.class.find(:to => {:clients => ["client1","client2"],:channels => "2"}).should eql([@connection3])
          end
          it "should return only connections from specified clients that include at last one of specified channels" do
            self.class.find(:to => {:clients => ["client1","client2"],:channels => ["2","1"]}).should eql([@connection2,@connection3])
          end
        end
      end
      
      context "on :except" do
        context "if :clients option is specified" do
          it "should return all connections if :clients is nil" do
            self.class.find(:except => {:clients => nil}).should eql(@connections)
          end
          it "should return all connections if :clients is empty" do
            self.class.find(:except => {:clients => []}).should eql(@connections)
          end
          it "should return all connections except of specified client" do
            self.class.find(:except => {:clients => "client1"}).should eql([@connection3,@connection4])
          end
          it "should return all connections except of specified clients if array provided" do
            self.class.find(:except => {:clients => ["client1","client2"]}).should eql([@connection4])
          end
        end
        context "if :channels option is specified" do
          it "should return all connections if :channels is nil" do
            self.class.find(:except => {:channels => nil}).should eql(@connections)
          end
          it "should return all connections if :channels is empty" do
            self.class.find(:except => {:channels => []}).should eql(@connections)
          end
          it "should return all connections except of that include all specified channels" do
            self.class.find(:except => {:channels => ["2","5"]}).should eql([@connection1,@connection2,@connection4])
          end
        end
        context "if both :clients and :channels options are provided" do
          context "but :channels are nil" do
            it "should return all connections except of specified client" do
              self.class.find(:except => {:channels => nil,:clients => "client1"}).should eql([@connection3,@connection4])
            end
            it "should return all connections except of specified clients if array provided" do
              self.class.find(:except => {:channels => nil,:clients => ["client1","client2"]}).should eql([@connection4])
            end
          end
          context "but :channels are empty" do
            it "should return all connections except of specified client" do
              self.class.find(:except => {:channels => [],:clients => "client1"}).should eql([@connection3,@connection4])
            end
            it "should return all connections except of provided clients if array provided" do
              self.class.find(:except => {:channels => [],:clients => ["client1","client2"]}).should eql([@connection4])
            end
          end
          context "but :clients are nil" do
            it "should return all connections except of that include all of specified channels" do
              self.class.find(:except => {:clients => nil,:channels => ["2","5"]}).should eql([@connection1,@connection2,@connection4])
            end
          end
          context "but :clients are empty" do
            it "should return all connections except of that include all of specified channels " do
              self.class.find(:except => {:clients => [],:channels => ["2","5"]}).should eql([@connection1,@connection2,@connection4])
            end
          end
          it "should return all connections except of specified client or all specified channels" do
            self.class.find(:except => {:clients => "client2",:channels => "3"}).should eql([@connection1,@connection2,@connection4])
            self.class.find(:except => {:clients => "client2",:channels => ["3","5"]}).should eql([@connection1,@connection2])
          end
          it "should return only connections from specified clients that include specified channel" do
            self.class.find(:except => {:clients => ["client1","client2"],:channels => "3"}).should eql([@connection4])
            self.class.find(:except => {:clients => ["client1","client2"],:channels => ["3","5"]}).should eql([])
          end
        end
      end
    
      context "on :to and :except" do
        context "should value 'except' more that 'to'" do
          it "on :client" do
            self.class.find(:to => {:clients => "client1"},:except => {:clients => "client1"}).should eql([])
          end
          it "on :channels" do
            self.class.find(:to => {:channels => "5"},:except => {:channels => "5"}).should eql([])
          end
          it "on :client allow and :channels except" do
            self.class.find(:to => {:clients => "client2"},:except => {:channels => ["2","5"]}).should eql([])
          end
          it "on :channels allow and :clients except" do
            self.class.find(:to => {:channels => ["5"]},:except => {:clients => "client2"}).should eql([@connection2,@connection4])
          end
        end
      end
    end
    
  end
end