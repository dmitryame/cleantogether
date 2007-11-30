class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.column :cleaning_event_id, :integer
      t.column "content_type", :string
      t.column "filename", :string     
      t.column "size", :integer
      
      # used with thumbnails, always required
      t.column "parent_id",  :integer 
      t.column "thumbnail", :string
      
      # required for images only
      t.column "width", :integer  
      t.column "height", :integer

      # required for db-based files only
      t.column "db_file_id", :integer
    end

    # only for db-based files
    create_table :db_files, :force => true do |t|
         t.column :data, :binary, :limit => 1.megabyte  
    end
    
    add_index :pictures, :cleaning_event_id
    
  end

  def self.down
    remove_index :pictures, :cleaning_event_id

    drop_table :pictures
    
    # only for db-based files
    drop_table :db_files
  end
end
