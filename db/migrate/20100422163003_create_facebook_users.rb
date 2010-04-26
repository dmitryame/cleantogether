class CreateFacebookUsers < ActiveRecord::Migration
  def self.up
    create_table :facebook_users do |t|
      t.string :facebook_id
      t.string :name
      t.string :first_name
      t.string :last_name
      t.string :link
      t.string :email
      t.integer :timezone
      t.string :token

      t.timestamps
    end
    
    rename_column :stories, :user_id, :facebook_user_id
    remove_column :pictures, :user_id
    
  end

  def self.down
    rename_column :stories, :facebook_user_id, :user_id
    add_column :pictures, :user_id, :integer
    
    drop_table :facebook_users
  end
end
