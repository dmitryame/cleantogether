require "bigdecimal"
require "bigdecimal/math"
class GeoLocation < ActiveRecord::Base
  validates_presence_of     :name
  validates_uniqueness_of   :name
  
  # def lat=(lat)
  #   self[:lat] = BigDecimal(lat, 14)
  # end
  # def lng=(lng)
  #   self[:lng] = BigDecimal(lng, 14)
  # end
  # 
  # 
  # def lng
  #   BigDecimal(lng_before_type_cast, 14)
  # end
  # def lat
  #   BigDecimal(lat_before_type_cast, 14)
  # end
end
