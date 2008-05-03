class ExpeditionsController < ApplicationController
  before_filter :login_required

  # code between these comments is redundant with stories controller has to be rafactored into a reusable component
  auto_complete_for :geo_location, :name
  # code between these comments is redundant with stories controller has to be rafactored into a reusable component

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


  # render new.rhtml
  def new
    @expedition = Expedition.new
    @expedition.captain = current_user
    @expedition.target_date = Time.today
    

    # code between these comments is redundant with stories controller has to be rafactored into a reusable component
    @recent_geo_locations = 
    GeoLocation.recent_geo_locations(current_user)
    
    @geo_location = GeoLocation.find(params[:geo_location_id]) if params[:geo_location_id] 

    if @geo_location == nil 
      @geo_location = @recent_geo_locations[0] 
    end
    if @geo_location == nil	
      @geo_location = GeoLocation.new 
    end
    # code between these comments is redundant with stories controller has to be rafactored into a reusable component

  end
  
  # POST /stories
  # POST /stories.xml
  def create
    @expedition = Expedition.new(params[:expedition])
    @expedition.captain = current_user

    @recent_geo_locations = 
    GeoLocation.recent_geo_locations(current_user)
    @geo_location = @expedition.geo_location 
    if @geo_location == nil
      flash[:error] = "Location is required"
      @geo_location = GeoLocation.new
    end


    respond_to do |format|
      if @expedition.save
        flash[:notice] = "New expedition was successfully created"
        format.html {redirect_to user_url(current_user) }
        # format.xml do
        #   headers["Location"] = client_url(@client)
        #   render :nothing => true, :status => "201 Created"
        # end
      else
        format.html {render :action => "new"}
        # format.xml {render :xml => @client.errors.to_xml}
      end
    end
  end


  def show 
    @expedition = current_user.captains_expeditions.find(params[:id])
    respond_to do |format| 
      format.html # show.rhtml 
      # format.xml { render :xml => @article.to_xml } 
    end 
  end 


  def edit
    @expedition = current_user.captains_expeditions.find(params[:id])
  end  
  
  def update 
    @expedition = current_user.captains_expeditions.find(params[:id])
    respond_to do |format| 
      if @expedition.update_attributes(params[:expedition]) 
        format.html { redirect_to user_expedition_url(current_user, @expedition) } 
        # format.xml { render :nothing => true } 
      else 
        format.html { render :action => "edit" } 
        # format.xml { render :xml => @article.errors.to_xml } 
      end 
    end 
  end 
  
  def destroy
    @expedition = current_user.captains_expeditions.find(params[:id])
    current_user.captains_expeditions.destroy(@expedition)
  end


end
