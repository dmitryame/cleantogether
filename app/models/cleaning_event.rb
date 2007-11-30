class CleaningEvent < ActiveRecord::Base
  has_one :picture
  belongs_to :user
  belongs_to :geo_location
  validates_numericality_of :weight
  validates_inclusion_of :weight, :in =>0..199
  
  def self.collected
    CleaningEvent.sum :weight
  end
  
  def self.count_events
    CleaningEvent.count :conditions => ["weight > ?", 0]
  end
  
end
