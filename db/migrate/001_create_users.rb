class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :login,            :string, :null  => false
      t.column :hashed_password, :string
      t.column :salt,            :string
      t.column :email,      :string,   :null      => false
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :created_at, :datetime, :null      => false
      t.column :updated_at, :datetime, :null      => false
    end
    add_index :users, :login
    add_index :users, :hashed_password
    add_index :users, :salt
    add_index :users, :email
    add_index :users, :first_name
    add_index :users, :last_name
  end

  def self.down
    remove_index :users, :login
    remove_index :users, :hashed_password
    remove_index :users, :salt
    remove_index :users, :email
    remove_index :users, :first_name
    remove_index :users, :last_name

    drop_table :users
  end
end
