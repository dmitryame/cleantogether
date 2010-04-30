class RemoveAccessToken < ActiveRecord::Migration
  def self.up
    remove_column :facebook_users, :token    
  end

  def self.down
    add_column :facebook_users, :token, :string
  end
end
