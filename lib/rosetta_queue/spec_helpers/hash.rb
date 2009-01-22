class Hash
  # To be used in conjuction with rspec's predicate matcher.
  #
  # For example, in story/feature or a functional spec you could say:  
  #
  # expected_message =  {'name' => 'Advertiser'}
  # expected_message.should be_published_to(:advertiser_create)
  #
  def published_to?(destination)
    received_message = nil
    begin
      Timeout::timeout(2) { received_message = RosettaQueue::Consumer.receive(destination)}
    rescue Timeout::Error
      raise "#{destination} should have received a message but did not NOTE: make sure there are no other processes which are polling messages"
    end
    
    # calling should == is kinda wierd, I know.. but in order to get a decent error message it is needed
    received_message.should ==  self
  end
  
end
