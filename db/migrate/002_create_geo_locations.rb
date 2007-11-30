class CreateGeoLocations < ActiveRecord::Migration
  def self.up
    create_table :geo_locations, :options => "ENGINE=MyISAM" do |t|
      t.column :name, :string, :null => false
      t.column :description, :text, :limit => 10.kilobyte
      t.column :lat, :decimal, :precision => 20, :scale => 15, :null => false
      t.column :lng, :decimal, :precision => 20, :scale => 15, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end
    add_column :users, :geo_location_id, :integer

    # add_index :geo_locations, :name,  :unique => true
    add_index :geo_locations, [:lat, :lng], :unique => true
    add_index :geo_locations, :lat
    add_index :geo_locations, :lng
  end

  def self.down
    # remove_index :geo_locations, :column => :name
    remove_index :geo_locations, :column => [:lat, :lng]
    remove_index :geo_locations, :lat
    remove_index :geo_locations, :lng

    remove_column :users, :geo_location_id

    drop_table :geo_locations
  end
end
