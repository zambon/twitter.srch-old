class Query < ActiveRecord::Base
  
  validate :presence_of_from_user_or_q
  validate :from_user_format
  
  validates_length_of :from_user, :maximum => 25, :allow_nil => true, :allow_blank => true
  validates_length_of :lang, :maximum => 2, :allow_nil => true, :allow_blank => true
  validates_length_of :q, :maximum => 140, :allow_nil => true, :allow_blank => true
  
  validates_numericality_of :rpp, :only_integer => true, :less_then => 100, :allow_nil => true
  
  validate :presence_of_rpp
  #validate :valid_since
  
  def presence_of_from_user_or_q
    errors.add_to_base("either 'from' or 'text' must be provided!") if (self.from_user.nil? or self.from_user.empty?) and (self.q.nil? or self.q.empty?)
  end
  
  def from_user_format
    if not (self.from_user.nil? or self.from_user.empty?)
      self.from_user = self.from_user[1, self.from_user] if self.from_user.starts_with?("@") or self.from_user.starts_with?("#")
    end
    true
  end
  
  def presence_of_rpp
    self.rpp = 15 unless not self.rpp.nil?
    self.rpp = 99 if self.rpp > 99
    true
  end
  
  def valid_since
    begin
      self.since = Date.parse(self.since) if not self.since.nil?
      true
    rescue
      errors.add_to_base("since is invalid")
      false
    end
  end
  
end
