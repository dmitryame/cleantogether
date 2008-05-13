class CreateSponsors < ActiveRecord::Migration
  def self.up
    create_table :sponsors do |t|
      t.column :name, :string, :null  => false
      t.column :url, :string
      t.column :email, :string
      t.column :logo_id, :integer
      t.timestamps
    end
    add_index :sponsors, :name
  end

  def self.down
    remove_index :sponsors, :name    
    drop_table :sponsors
  end
end
