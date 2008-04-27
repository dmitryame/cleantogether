require "bigdecimal"
require "bigdecimal/math"
class GeoLocation < ActiveRecord::Base
  has_many :stories
  validates_presence_of     :name, :lat, :lng
  validates_uniqueness_of   :name

  def self.recent_geo_locations(p_user_id)
    GeoLocation.find(:all, :order => 'stories.cleaning_at DESC', :include => :stories, :limit => 10, 
        :conditions => { 'stories.user_id' => p_user_id }) 
  end

  def validate
    if(lat == nil || lat == 0 || lat.nan?) && (lng == nil || lng == 0 || lng.nan?)
      errors.add("Marker is not set")
    end
  end
end
