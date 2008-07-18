module Filterable

  def attributes=(lead_hash)
    super(lead_hash.reject { |k,v| !self.class.column_names.include?(k) })
  end

end