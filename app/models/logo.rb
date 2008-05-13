class Logo < ActiveRecord::Base
  has_attachment :content_type => :image
  validates_as_attachment
  
  has_many :sponsors
end
