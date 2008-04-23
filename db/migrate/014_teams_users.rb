class TeamsUsers < ActiveRecord::Migration
  def self.up
      create_table :teams_users, :id => false do |t|
        t.references :team, :user, :null => false
        t.timestamps 
      end

      add_index :teams_users, [ :team_id, :user_id ]
      add_index :teams_users, :user_id

    end

    def self.down
      remove_index :teams_users, :teams_users
      remove_index :teams_users, :user_id
      
      drop_table :teams_users
  end
end
