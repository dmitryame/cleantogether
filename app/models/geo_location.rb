require "bigdecimal"
require "bigdecimal/math"
class GeoLocation < ActiveRecord::Base
  has_many :cleaning_events
  validates_presence_of     :name, :description, :lat, :lng
  validates_uniqueness_of   :name

  def self.recent_geo_locations(p_user_id)
    GeoLocation.find(:all, :order => 'cleaning_events.cleaning_at DESC', :include => :cleaning_events, :limit => 10, 
        :conditions => { 'cleaning_events.user_id' => p_user_id }) 
  end

  def validate
    if(lat == nil || lat == 0 || lat.nan?) && (lng == nil || lng == 0 || lng.nan?)
      errors.add("Marker is not set")
    end
  end
end
