class Story < ActiveRecord::Base
  has_many :pictures
  belongs_to :user
  belongs_to :geo_location  
  
  validates_presence_of :geo_location, :on => :create
  validates_presence_of :weight, :on => :create
  validates_presence_of :cleaning_at, :on => :create
  validates_numericality_of :weight
  validates_inclusion_of :weight, :in =>1..200, :message => "out of range 1-200"
  
  def self.collected
    Story.sum :weight
  end
  
  def self.count_events
    Story.count :conditions => ["weight > ?", 0]
  end
  
end
