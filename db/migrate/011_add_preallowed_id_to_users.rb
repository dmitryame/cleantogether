class AddPreallowedIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :preallowed_id, :integer
  end

  def self.down
    remove_column :users, :preallowed_id
  end
end
