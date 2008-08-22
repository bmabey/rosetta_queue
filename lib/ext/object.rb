class Object
  def tap
    yield self if block_given?
    self
  end
  
  def try(message)
    if self.respond_to?(message.to_sym)
      return self.send(message.to_sym)
    else
      return nil
    end
  end
  
end