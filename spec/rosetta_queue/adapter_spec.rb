require File.dirname(__FILE__) + '/../spec_helper'

module RosettaQueue

  describe Adapter do

    before(:each) do
      @stomp_adapter = mock("Gateway::StompAdapter")
      Adapter.reset
    end

    describe ".reset" do
      it "should clear all definitions" do
        Adapter.define { |a| a.type = "null"  }
        Adapter.instance.should be_instance_of(RosettaQueue::Gateway::NullAdapter)
        Adapter.reset
        running { Adapter.instance }.should raise_error(AdapterException)
      end
    end

    describe ".type=" do

      it "should raise error when adapter does not exist" do
        running {
          Adapter.define do |a|
            a.type = "foo"
          end
          }.should raise_error(AdapterException)
      end

    end

    describe "adapter not type set" do
      it "should raise an error when .instance is called" do
        # given
        Adapter.define { |a|  }
        # then & when
        running { Adapter.instance }.should raise_error(AdapterException)
      end
    end

    describe "adapter type set" do

      before(:each) do
        Adapter.define { |a| a.type = "null" }
      end

      it "should return adapter instance" do
        Adapter.instance.class.should == RosettaQueue::Gateway::NullAdapter
      end

    end

    describe "adapter instantiation" do

      before(:each) do
        Adapter.define do |a|
          a.user = "foo"
          a.password = "bar"
          a.host = "localhost"
          a.port = "9000"
          a.type = "fake"
        end
      end

      def do_process
        Adapter.instance
      end

      it "should set opts as an empty has unless variable is set" do
        during_process {
          RosettaQueue::Gateway::FakeAdapter.should_receive(:new).with({:user => "foo", :password => "bar", :host => "localhost", :port => "9000", :opts => {}})
        }
      end

      describe "when setting options" do
        before(:each) do
          Adapter.define { |a| a.options = {:vhost => "baz"} }
        end

        it "should map adapter_settings to a hash" do
          during_process {
            RosettaQueue::Gateway::FakeAdapter.should_receive(:new).with({:user => "foo", :password => "bar", :host => "localhost", :port => "9000", :opts => {:vhost => "baz"}})
          }
        end
      end

      describe "setting options incorrectly (options should always be set as a Hash)" do

        before(:each) do
          Adapter.define { |a| a.options = "baz" }
        end

        it "should raise an adapter exception" do
          running { Adapter.instance }.should raise_error("Adapter options should be a hash")
        end
      end

    end
  end
end
