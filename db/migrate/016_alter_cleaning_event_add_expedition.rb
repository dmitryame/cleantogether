class AlterCleaningEventAddExpedition < ActiveRecord::Migration
  def self.up
    add_column :cleaning_events, :expedition_id, :integer
    add_index :cleaning_events, :expedition_id
  end

  def self.down
    remove_index :cleaning_events, :column_name
    remove_column :cleaning_events, :expedition_id
  end
end
