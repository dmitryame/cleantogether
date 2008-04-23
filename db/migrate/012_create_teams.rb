class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.column :name, :string, :null         => false
      t.column :motto, :string
      t.column :captain_id, :integer, :null  => false      
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end
    add_index :teams, :captain_id
  end

  def self.down
    remove_index :teams, :captain_id

    drop_table :teams
  end
end
