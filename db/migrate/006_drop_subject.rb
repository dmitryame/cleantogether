class DropSubject < ActiveRecord::Migration
  def self.up
    remove_column :cleaning_events, :subject
  end

  def self.down
    add_column :cleaning_events, :subject, :string
  end
end
