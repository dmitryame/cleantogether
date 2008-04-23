class RenameUsersTable < ActiveRecord::Migration
  def self.up
    rename_table :users, :users_old
  end

  def self.down
    rename_table :users_old, :users
  end
end
