class Hash
  # To be used in conjuction with rspec's boolean matcher.
  #
  # For example, in a spec or story you could say:  
  #
  # expected_message =  {'name' => 'Advertiser'}
  # expected_message.should be_published_to(:advertiser_create)
  #
  def published_to?(destination)
    Messaging::Consumer.receive(destination) == self.to_json
  end
  
end