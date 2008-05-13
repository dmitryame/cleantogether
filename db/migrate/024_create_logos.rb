class CreateLogos < ActiveRecord::Migration
  def self.up
    create_table :logos do |t|
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
      t.timestamps
    end
  end

  def self.down
    drop_table :logos
  end
end
