class AlterCleaningEventCleanAt < ActiveRecord::Migration
  def self.up
    change_column :cleaning_events, :cleaning_at, :datetime, :null => false
  end

  def self.down
    change_column :cleaning_events, :cleaning_at, :date, :null => false
  end
end
