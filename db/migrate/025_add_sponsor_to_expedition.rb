class AddSponsorToExpedition < ActiveRecord::Migration
  def self.up
    add_column :expeditions, :sponsor_id, :integer
    add_index :expeditions, :sponsor_id
  end

  def self.down
    remove_index :expeditions, :sponsor_id
    remove_column :expeditions, :sponsor_id
  end
end
