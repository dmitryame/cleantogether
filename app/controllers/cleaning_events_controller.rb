class CleaningEventsController < ApplicationController
  before_filter :login_required
  
  before_filter :find_user

  in_place_edit_for :cleaning_event, :weigth
  in_place_edit_for :cleaning_event, :blog

  auto_complete_for :geo_location, :name

  # in_place_editor_filed helper methods

  def set_cleaning_event_blog
    @cleaning_event = CleaningEvent.find(params[:id])
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
    @cleaning_event.blog = final_line    
    @cleaning_event.save
  end
  def set_cleaning_event_weight
    @cleaning_event = CleaningEvent.find(params[:id])
    value = ERB::Util.h(params[:value])
    value = 0 if value == nil || value.strip == ''
    @cleaning_event.weight = value 
    @cleaning_event.save
  end

  # END in_place_editor_filed helper methods 

  def update_cleaning_at
    @cleaning_event = CleaningEvent.find(params[:id])
    @cleaning_event.cleaning_at = params[:cleaning_at]
    @cleaning_event.save
  end

  def index
    @cleaning_events = CleaningEvent.paginate_by_user_id session[:user_id], :page => params[:page],:per_page => 10, :order => "created_at DESC"
  end


  # GET /cleaning_events/new
  def new

    @cleaning_event = CleaningEvent.new
    @cleaning_event.cleaning_at = Time.today

    @recent_geo_locations = 
    GeoLocation.recent_geo_locations(session[:user_id])

    if params[:geo_location_id] != nil
      @geo_location = GeoLocation.find(params[:geo_location_id]) 
    end
    if @geo_location == nil 
      @geo_location = @recent_geo_locations[0] 
    end
    if @geo_location == nil	
      @geo_location = GeoLocation.new 
    end

  end


  # GET /cleaning_events/1/edit
  # def edit
  #   @cleaning_event = CleaningEvent.find(params[:id])
  # end    

  # POST /cleaning_events
  # POST /cleaning_events.xml
  def create
    @cleaning_event = CleaningEvent.new(params[:cleaning_event])
    @cleaning_event.user_id = @user.user_id
    if(@cleaning_event.blog == nil || @cleaning_event.blog.strip == '')
      @cleaning_event.blog = '[Click here to write up a short BLOG story about the event...]'
    end

    @recent_geo_locations = 
    GeoLocation.recent_geo_locations(@cleaning_event.user)
    @geo_location = @cleaning_event.geo_location 
    if @geo_location == nil
      flash[:error] = "Location is required"
      @geo_location = GeoLocation.new
    end

    respond_to do |format|
      if @cleaning_event.save
        flash[:notice] = "Event was successfully created"
        format.html {redirect_to cleaning_events_url }
        # format.xml do
        #   headers["Location"] = client_url(@client)
        #   render :nothing => true, :status => "201 Created"
        # end
      else
        flash[:error] = "Oops, something went wrong, correct the errors below and resubmit..." if flash[:error] == nil
        format.html {render :action => "new"}
        # format.xml {render :xml => @client.errors.to_xml}
      end
    end
  end

  def destroy
    @cleaning_event = CleaningEvent.find(params[:id])

    @cleaning_event.pictures.each do |picture|
      Picture.destroy(picture)
    end
    CleaningEvent.destroy(@cleaning_event)    
  end

  def select_location
    @geo_location = GeoLocation.find(params[:id])
    @marker = GMarker.new([@geo_location.lat, @geo_location.lng],:title => @geo_location.description) 
    @map = Variable.new("map")

    @map.control_init(:large_map => true,:map_type => true)                  
    # @map.set_map_type_init(GMapType::G_HYBRID_MAP)                   
    @map.center_zoom_init([@geo_location.lat,@geo_location.lng],8)                 
    @map.overlay_init @marker             
  end

  def complete_location
    @geo_location = GeoLocation.find_by_name(params[:id])
    @marker = GMarker.new([@geo_location.lat, @geo_location.lng],:title => @geo_location.description) 
    @map = Variable.new("map")

    @map.control_init(:large_map => true,:map_type => true)                  
    # @map.set_map_type_init(GMapType::G_HYBRID_MAP)                   
    @map.center_zoom_init([@geo_location.lat,@geo_location.lng],8)                 
    @map.overlay_init @marker                 
  end  


  def upload_picture
    @picture = Picture.create! params[:picture]

    @cleaning_event = CleaningEvent.find(params[:cleaning_event_id])
    @picture.cleaning_event = @cleaning_event
    @picture.save

    if @cleaning_event.save
      responds_to_parent do
        render :update do |page|
          page.replace "cleaning-event-picture-#{@cleaning_event.id}", :partial => 'cleaning_event_picture', :object => @cleaning_event
          page["cleaning-event-picture-#{@cleaning_event.id}"].visual_effect :slide_down
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
  def find_user    
    user_id = params[:user_id]
    @user = User.find(user_id)
    debugger
  end
end