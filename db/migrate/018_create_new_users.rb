class CreateNewUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :login,                     :string
      t.column :email,                     :string
      t.column :crypted_password,          :string, :limit  => 40
      t.column :salt,                      :string, :limit  => 40
      t.column :created_at,                :datetime, :null => false
      t.column :updated_at,                :datetime, :null => false
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column :activation_code, :string, :limit            => 40
      t.column :activated_at, :datetime
      t.column :password_reset_code, :string, :limit        => 40
      t.column :enabled, :boolean, :default                 => true
      #custom code
      t.column :preallowed_id, :integer
      
    end
    add_index :uesrs, :email
    add_index :uesrs, :activation_code
  end

  def self.down
    remove_index :uesrs, :activation_code
    remove_index :uesrs, :email
    
    drop_table "users"
  end
end
