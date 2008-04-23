class ExpeditionsTeams < ActiveRecord::Migration
  def self.up
      create_table :expeditions_teams, :id => false do |t|
        t.references :expedition, :team, :null => false
        t.column :geo_location_id, :integer        
        t.column :cleaning_at, :date, :null => false        
        t.timestamps 
      end

      add_index :expeditions_teams, [ :expedition_id, :team_id ]
      add_index :expeditions_teams, :team_id

    end

    def self.down
      remove_index :expeditions_teams, :expeditions_teams
      remove_index :expeditions_teams, :team_id
      
      drop_table :expeditions_teams
  end
end
