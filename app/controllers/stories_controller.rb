class StoriesController < ApplicationController
 before_filter :authorize, :only => :new
  # code between these comments is redundant with expeditions controller has to be rafactored into a reusable component
  auto_complete_for :geo_location, :name
  # code between these comments is redundant with expeditions controller has to be rafactored into a reusable component
  # auto_complete_for :team, :name

  def index    
    @stories = Story.paginate :page => params[:page],:per_page => 10, :conditions => ['facebook_user_id = ?', "#{@current_user.id}"], :order => "created_at DESC"
  end


  # GET /stories/new
  def new
    if @current_user == nil
      
    end
    @story = Story.new
    @story.cleaning_at = Date.today

    init_defaults
    
  end

  def edit
    @story = @current_user.stories.find(params[:id])
  end  

  def show
    @story = FacebookUser.find(params[:facebook_user_id]).stories.find(params[:id])
  end  


  def update 
    @story = @current_user.stories.find(params[:id])
    respond_to do |format| 
      if @story.update_attributes(params[:story]) 
        flash[:notice] = "Story updated"
        format.html { redirect_to facebook_user_stories_url(@current_user) } 
        # format.xml { render :nothing => true } 
      else 
        format.html { render :action => "edit" } 
        # format.xml { render :xml => @article.errors.to_xml } 
      end 
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
    @story.facebook_user = @current_user
    if(@story.blog == nil || @story.blog.strip == '')
    end

    init_defaults

    if @story.save
      flash[:notice] = "Event was successfully created"
      redirect_to facebook_user_stories_url(@current_user)
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
    @picture = Picture.new(params[:picture])

    @story = Story.find(params[:story_id])
    @picture.story = @story
    @picture.save

    if @story.save
      responds_to_parent do
        render :update do |page|
          page.insert_html :bottom, dom_id(@story, "story_images"), :partial => 'story_picture', :object => @picture
          page[dom_id(@picture)].visual_effect :grow
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

  def delete_picture
    @picture = Picture.find params[:id]
    @picture.destroy
  end

  # def join_team    
  #   @team = Team.find_by_name(params[:name])
  #   if(!@current_user.teams.find_by_name(@team.name))
  #     current_user.teams << @team 
  #     init_defaults      
  #   end
  # end  
  # 
  # def leave_team
  #   @team = Team.find(params[:id])
  #   current_user.teams.delete(@team)
  #   init_defaults
  # end


  private
  def init_defaults
    @recent_geo_locations = 
    GeoLocation.recent_geo_locations(@current_user)

    @geo_location = GeoLocation.find(params[:geo_location_id]) if params[:geo_location_id] 

    if @geo_location == nil 
      @geo_location = @recent_geo_locations[0] 
    end
    if @geo_location == nil	
      @geo_location = GeoLocation.new 
    end

  end  

end