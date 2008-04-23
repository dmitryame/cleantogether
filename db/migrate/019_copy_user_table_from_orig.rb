class CopyUserTableFromOrig < ActiveRecord::Migration
  def self.up
    rename_table :users_old, :old_users
    
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    
    OldUser.find(:all).each do |old_user|
      puts "adding user " + old_user.login
      user                       = User.new
      user.id                    = old_user.id
      user.first_name            = old_user.first_name
      user.last_name             = old_user.last_name
      user.created_at            = old_user.created_at
      user.updated_at            = old_user.updated_at
      user.login                 = old_user.login
      user.email                 = old_user.email
      user.password              = "super_secret1qa"  
      user.password_confirmation = "super_secret1qa"
      user.preallowed_id         = old_user.preallowed_id
      #debugger
      user.save

    end
    
    add_index :users, :login
    add_index :users, :email
    add_index :users, :first_name
    add_index :users, :last_name
        
    drop_table "old_users"
  end

  def self.down
    create_table :old_users do |t|
      t.column :login,            :string
      t.column :hashed_password, :string
      t.column :salt,            :string
      t.column :email,      :string,   :null      => false
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :created_at, :datetime, :null      => false
      t.column :updated_at, :datetime, :null      => false
      t.column :preallowed_id, :integer
    end
    
    add_index :old_users, :login
    add_index :old_users, :email
    add_index :old_users, :first_name
    add_index :old_users, :last_name 
    

    User.find(:all).each do |user|
      puts "transfering old_user " + user.login
      old_user                       = OldUser.new
      old_user.id                    = user.id
      old_user.first_name            = user.first_name
      old_user.last_name             = user.last_name
      old_user.created_at            = user.created_at
      old_user.updated_at            = user.updated_at
      old_user.login                 = user.login
      old_user.email                 = user.email
      old_user.password              = "super_secret1qa"
      old_user.password_confirmation = "super_secret1qa"
      old_user.preallowed_id         = user.preallowed_id
      old_user.save

    end

    remove_index :users, :login
    remove_index :users, :email
    remove_index :users, :first_name
    remove_index :users, :last_name
 
    remove_column :users, :first_name
    remove_column :users, :last_name
    
    rename_table :old_users, :users_old
    
  end
end
