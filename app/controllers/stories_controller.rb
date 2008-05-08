class StoriesController < ApplicationController
  before_filter :login_required
  
  in_place_edit_for :story, :weigth
  in_place_edit_for :story, :blog

  # code between these comments is redundant with expeditions controller has to be rafactored into a reusable component
  auto_complete_for :geo_location, :name
  # code between these comments is redundant with expeditions controller has to be rafactored into a reusable component

  # in_place_editor_filed helper methods

  def set_story_blog
    @story = Story.find(params[:id])
    value = ERB::Util.h(params[:value])

    s = StringScanner.new(value)
    final_line = value
    # final_line = ""
    # count = 0
    # while !s.eos?  
    #   next_char = s.getch()   
    #   if(count <= 80)
    #     if(next_char == "\n")
    #       count = 0
    #     else
    #       count += 1
    #     end
    #     final_line += next_char 
    #   else
    #     count = 0
    #     final_line += "\n" 
    #     final_line += next_char if next_char != "\n"
    #   end      
    # end
    final_line = '[Enter Description]' if final_line == nil || final_line.strip == ''
    @story.blog = final_line    
    @story.save
  end
  
  
  def set_story_weight
    @story = Story.find(params[:id])
    value = ERB::Util.h(params[:value])
    value = 0 if value == nil || value.strip == ''
    @story.weight = value 
    @story.save
  end

  # END in_place_editor_filed helper methods 

  def update_cleaning_at
    @story = Story.find(params[:id])
    @story.cleaning_at = params[:cleaning_at]
    @story.save
  end

  def index
    @stories = Story.paginate_by_user_id current_user, :page => params[:page],:per_page => 10, :order => "created_at DESC"
  end


  # GET /stories/new
  def new
    @story = Story.new
    @story.cleaning_at = Time.today

    init_defaults
    
  end

  def select_expedition
    if params[:id] != "0" && params[:id] != nil && params[:id] != ""       
      @expedition = Expedition.find(params[:id]) 
      @geo_location = @expedition.geo_location
      @marker = GMarker.new([@geo_location.lat, @geo_location.lng],:title => @geo_location.description) 

      @map = Variable.new("map")

      @map.control_init(:large_map => true,:map_type => true)                  
      # @map.set_map_type_init(GMapType::G_HYBRID_MAP)                   
      @map.center_zoom_init([@geo_location.lat,@geo_location.lng],8)                 
      @map.overlay_init @marker             
    end
  end


  # def story_with_location
  #   @geo_location = GeoLocation.find(params[:geo_location_id])
  #   render :action => "new" 
  # end

  # GET /stories/1/edit
  # def edit
  #   @story = Story.find(params[:id])
  # end    

  # POST /stories
  # POST /stories.xml
  def create
    @story = Story.new(params[:story])
    @story.user = current_user
    if(@story.blog == nil || @story.blog.strip == '')
      @story.blog = '[Click here to write up a short BLOG story about the event...]'
    end

    init_defaults

    if(@story.expedition) # force some story fields to expedition's values
      @expedition = @story.expedition
      @story.geo_location = @expedition.geo_location
      @story.cleaning_at = @expedition.target_date
    end

    if @story.save
      flash[:notice] = "Event was successfully created"
      redirect_to stories_url 
    else
      flash[:error] = "Oops, something went wrong, correct the errors below and resubmit..." if flash[:error] == nil
      render :action => "new"
    end
  end

  def destroy
    @story = Story.find(params[:id])

    @story.pictures.each do |picture|
      Picture.destroy(picture)
    end
    Story.destroy(@story)    
  end

  # code between these comments is redundant with stories/expeditions -- has to be rafactored into a reusable component
  def select_location
    @geo_location = GeoLocation.find(params[:id])
    @marker = GMarker.new([@geo_location.lat, @geo_location.lng],:title => @geo_location.description) 
    @map = Variable.new("map")

    @map.control_init(:large_map => true,:map_type => true)                  
    # @map.set_map_type_init(GMapType::G_HYBRID_MAP)                   
    @map.center_zoom_init([@geo_location.lat,@geo_location.lng],8)                 
    @map.overlay_init @marker             
  end
  # code between these comments is redundant with stories/expeditions -- has to be rafactored into a reusable component

  # code between these comments is redundant with stories/expeditions -- has to be rafactored into a reusable component
  def complete_location
    @geo_location = GeoLocation.find_by_name(params[:id])
    @marker = GMarker.new([@geo_location.lat, @geo_location.lng],:title => @geo_location.description) 
    @map = Variable.new("map")

    @map.control_init(:large_map => true,:map_type => true)                  
    # @map.set_map_type_init(GMapType::G_HYBRID_MAP)                   
    @map.center_zoom_init([@geo_location.lat,@geo_location.lng],8)                 
    @map.overlay_init @marker                 
  end  
  # code between these comments is redundant with stories/expeditions -- has to be rafactored into a reusable component


  def upload_picture
    @picture = Picture.create! params[:picture]

    @story = Story.find(params[:story_id])
    @picture.story = @story
    @picture.save

    if @story.save
      responds_to_parent do
        render :update do |page|
          page.replace "story-picture-#{@story.id}", :partial => 'story_picture', :object => @story
          page["story-picture-#{@story.id}"].visual_effect :slide_down
        end
      end
    else
      responds_to_parent do
        render :update do |page|
          # update the page with an error message
        end
      end
    end
    # redirect_to :controller => "cleaning", :action => "index"

  end

  private
  def init_defaults
    # code between these comments is redundant with expeditions controller has to be rafactored into a reusable component
    @recent_geo_locations = 
    GeoLocation.recent_geo_locations(current_user)

    @geo_location = GeoLocation.find(params[:geo_location_id]) if params[:geo_location_id] 

    if @geo_location == nil 
      @geo_location = @recent_geo_locations[0] 
    end
    if @geo_location == nil	
      @geo_location = GeoLocation.new 
    end
    # code between these comments is redundant with expeditions controller has to be rafactored into a reusable component

    @my_expeditions = Expedition.recent_expeditions(current_user)
  end  

end