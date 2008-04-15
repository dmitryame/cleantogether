class DropGeoLocationIdFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :geo_location_id
  end

  def self.down
    add_column :users, :geo_location_id, :integer
  end
end
