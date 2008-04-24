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
      #custom code
      t.column :preallowed_id, :integer
      
    end
  end

  def self.down
    drop_table "users"
  end
end