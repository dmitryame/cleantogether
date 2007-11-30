class CreateCleaningEvents < ActiveRecord::Migration
  def self.up
    create_table :cleaning_events do |t|
      t.column :user_id, :integer, :null => false
      t.column :subject, :string
      t.column :blog, :text, :limit => 10.kilobytes
      t.column :geo_location_id, :integer
      t.column :weight, :integer, :default => 0, :null => false
      # t.column :picture_id, :integer
      t.column :cleaning_at, :date, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end
    add_index :cleaning_events, :user_id
    add_index :cleaning_events, :geo_location_id
    add_index :cleaning_events, :cleaning_at
  end

  def self.down
    remove_index :cleaning_events, :user_id
    remove_index :cleaning_events, :geo_location_id
    remove_index :cleaning_events, :cleaning_at

    drop_table :cleaning_events
  end
end
