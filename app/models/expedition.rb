class Expedition < ActiveRecord::Base
  belongs_to :captain,
  :class_name  => "User",
  :foreign_key => "captain_id"

  has_and_belongs_to_many :teams

  belongs_to :geo_location

  validates_presence_of :name
  validates_presence_of :target_date
  # validates_uniqueness_of :name



  # returns all expeditions available for user to post to based on the teams the user is in. 
  # If the user already posted a story to oa particular expedition, it's excluded from the list -- one post per user per expeedition.
  def self.recent_expeditions(user)
    my_expeditions = Array.new
    null_expedition = Expedition.new()
    null_expedition.id = 0
    my_expeditions <<  null_expedition # used as a nil object design pattern to show no expedition idem in the drop down 
    my_expeditions += Expedition.find(:all, 
    :include => {:teams => :users},
    :conditions => {'users.id' => user.id},
    :order => "target_date DESC",
    :limit => 25
    )
    my_expeditions
  end
  
end
