class Picture < ActiveRecord::Base
  has_attachment :content_type => :image,
                     :max_size => 10.megabyte,
                     # :resize_to => '640>',
                     :thumbnails => { :normal => '400>', :thumb => '100>' },
                     :processor  => "ImageScience"
  validates_as_attachment
  belongs_to :story
end
