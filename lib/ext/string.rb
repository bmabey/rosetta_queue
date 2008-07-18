class String
  def to_hash_from_json
    ActiveSupport::JSON.decode(self)
  end 
end