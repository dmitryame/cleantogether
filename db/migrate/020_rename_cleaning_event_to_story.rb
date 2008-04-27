class RenameCleaningEventToStory < ActiveRecord::Migration
  def self.up
    rename_table :cleaning_events, :stories
  end

  def self.down
    rename_table :stories, :cleaning_events 
  end
end
