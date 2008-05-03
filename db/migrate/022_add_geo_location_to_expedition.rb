class AddGeoLocationToExpedition < ActiveRecord::Migration
  def self.up
    add_column :expeditions, :geo_location, :integer, :null => false
  end

  def self.down
    remove_column :expeditions, :geo_location
  end
end
