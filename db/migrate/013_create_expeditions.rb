class CreateExpeditions < ActiveRecord::Migration
  def self.up
    create_table :expeditions do |t|
      t.column :name, :string, :null          => false
      t.column :target_date, :datetime, :null => false
      t.column :captain_id, :integer, :null   => false      
      t.column :created_at, :datetime, :null  => false
      t.column :updated_at, :datetime, :null  => false
    end
    add_index :expeditions, :captain_id
  end

  def self.down
    remove_index :expeditions, :captain_id

    drop_table :teams
  end
end
