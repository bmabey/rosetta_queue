require File.dirname(__FILE__) + '/../spec_helper'

module RosettaQueue

  describe ExceptionHandler do

    after(:each) do
      ExceptionHandler.reset_handlers
    end


    describe "::handle" do
      it "runs the given block returning the block's return value" do
        ExceptionHandler::handle do
          "foo"
        end.should == "foo"
      end

      it "delegates raised exceptions to each related registered handler" do
        # given
        ExceptionHandler::register(:consuming, registered_handler = mock('exception handling'))
        ExceptionHandler::register(:consuming, registered_handler2 = mock('exception handling'))
        exception = StandardError.new
        # expect
        registered_handler.should_receive(:handle).with(exception, anything)
        registered_handler2.should_receive(:handle).with(exception, anything)
        # when
        ExceptionHandler::handle(:consuming) do
          raise exception
        end
      end

      it "does not delegate raised exceptions to unrelated handlers" do
        # given
        ExceptionHandler::register(:consuming, consuming_handler = mock('consumner handling'))
        ExceptionHandler::register(:publishing, publishing_handler = mock('publishing handling'))
        exception = StandardError.new
        # expect
        consuming_handler.should_receive(:handle).with(exception, anything)
        publishing_handler.should_not_receive(:handle)
        # when
        ExceptionHandler::handle(:consuming) do
          raise exception
        end
      end

      it "delegates all types of messaging exceptions to handlers registered under ':all'" do
        # given
        ExceptionHandler::register(:all, messaging_handler = mock('global message exception handling'))
        exception = StandardError.new
        # expect
        messaging_handler.should_receive(:handle).with(exception, anything).twice
        # when
        ExceptionHandler::handle(:consuming) { raise exception }
        ExceptionHandler::handle(:publishing) { raise exception }
      end

      it "passes any additional information (in form of a hash) to the registered handlers" do
        # given
        ExceptionHandler::register(:all, messaging_handler = mock('global message exception handling'))
        info_hash = {:message => "this caused failure", :foo => "bar"}
        # expect
        messaging_handler.should_receive(:handle).with(anything, info_hash)
        # when
        ExceptionHandler::handle(:consuming, info_hash) { raise "FAIL" }
      end

      it "accepts a lambda for info and will pass it's evaluation along to the registered handlers" do
        # given
        ExceptionHandler::register(:all, messaging_handler = mock('global message exception handling'))
        info_hash = {:message => "this caused failure", :foo => "bar"}
        # expect
        messaging_handler.should_receive(:handle).with(anything, info_hash)
        # when
        ExceptionHandler::handle(:consuming, lambda { info_hash }) { raise "FAIL" }

      end


      it "reraises the error when no handlers have been registed for the given action" do
        ExceptionHandler::register(:consuming, consuming_handler = mock('consumner handling'))
        running do
          ExceptionHandler::handle(:publishing, {}) { raise "Foo" }
        end.should raise_error(RuntimeError)
      end


    end

    describe "::register" do
      # see the examples for ::handle as well- since they are related.

      it "takes an exception handling block in place of a class" do
        # given
        ExceptionHandler::register(:all) do |exception, info|
          RosettaQueue.logger.error "whoops"
        end
        # expect
        RosettaQueue.logger.should_receive(:error).with("whoops")
        # when
        ExceptionHandler::handle(:consuming) { raise "FAIL" }
      end
    end
  end

end
