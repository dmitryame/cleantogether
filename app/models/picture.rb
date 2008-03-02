class Picture < ActiveRecord::Base
  has_attachment :content_type => :image,
                     :max_size => 10.megabyte,
                     :resize_to => '640>',
                     :thumbnails => { :normal => '400>', :thumb => '100>' }
  validates_as_attachment
  belongs_to :cleaning_event
  belongs_to :user
end
