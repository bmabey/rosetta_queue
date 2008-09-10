class Hash
  # To be used in conjuction with rspec's predicate matcher.
  #
  # For example, in story/feature or a functional spec you could say:  
  #
  # expected_message =  {'name' => 'Advertiser'}
  # expected_message.should be_published_to(:advertiser_create)
  #
  def published_to?(destination)
    # calling should == is kinda wierd, I know.. but in order to get a decent error message it is needed
    Messaging::Consumer.receive(destination).to_hash_from_json.should ==  self
  end
  
end