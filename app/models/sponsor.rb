class Sponsor < ActiveRecord::Base
  validates_presence_of     :name, :url, :email
  validates_length_of       :email,    :within => 6..100
  validates_uniqueness_of   :name, :email, :case_sensitive => false
  validates_format_of       :email, :with => /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i

  belongs_to :logo
  
  has_many :expeditions
  
end
