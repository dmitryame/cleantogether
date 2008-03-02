class AlterDropGeoLocationsLatLngIndex < ActiveRecord::Migration
  def self.up
    remove_index :geo_locations, :column => [:lat, :lng]
  end

  def self.down
    add_index :geo_locations, [:lat, :lng], :unique => true
  end
end
