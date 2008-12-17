module RosettaQueue

  describe "a messaging gateway object", :shared => true do  
    
    it "#unsubscribe should be delegated to the adapter" do      
      pending
      # expect
      adapter.should_receive("unsubscribe")
      # when
      gateway.unsubscribe
    end
    
    it "#disconnect should be delegated to the adapter" do
      # expect
      adapter.should_receive("disconnect")
      # when
      gateway.disconnect
    end
  
  end
end