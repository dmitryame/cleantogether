class RenameCleaningEventToStoryInPicturesTable < ActiveRecord::Migration
  def self.up
    rename_column :pictures, :cleaning_event_id, :story_id
  end

  def self.down
    rename_column :pictures, :story_id, :cleaning_event_id
  end
end
