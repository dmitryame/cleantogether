class LocationEditorController < ApplicationController

  before_filter :check_authentication

  in_place_edit_for :geo_location, :name
  in_place_edit_for :geo_location, :description
  
  def set_geo_location_name
    @geo_location = session[:geo_location]
    # debugger
    value = ERB::Util.h(params[:value])
    value = '[Enter Location Name]' if value == nil || value.strip == ''
    @geo_location.name = value 
    session[:geo_location] = @geo_location
  end
  
  def set_geo_location_description
    @geo_location = session[:geo_location]
    value = ERB::Util.h(params[:value])
   
    s = StringScanner.new(value)
    final_line = ""
    count = 0
    while !s.eos?  
      next_char = s.getch()   
      if(count <= 80)
        if(next_char == "\n")
          count = 0
        else
          count += 1
        end
        final_line += next_char 
      else
        count = 0
        final_line += "\n" 
        final_line += next_char if next_char != "\n"
      end      
    end
    final_line = '[Enter Description]' if final_line == nil || final_line.strip == ''
    @geo_location.description = final_line    
    session[:geo_location] = @geo_location
  end
  
  # END in_place_editor_filed helper methods 


  def index
    @cleaning_event = CleaningEvent.find(params[:id])
    
    @map = GMap.new("map_div")
    @map.control_init(:large_map => true,:map_type => true)
    @map.icon_global_init(GIcon.new(:image => "http://labs.google.com/ridefinder/images/mm_20_green.png", :icon_size => GSize.new(15,15),:icon_anchor => GPoint.new(7,7),:info_window_anchor => GPoint.new(9,2)),"icon_standard")
    icon_standard = Variable.new("icon_standard")
    
    # if the event already assotiated with the location, use it, otherwise create a new one
    @geo_location  = @cleaning_event.geo_location
    if(@geo_location == nil)
      geo_coding_results = Geocoding::get('Crane Beach, MA')
      if geo_coding_results.status == Geocoding::GEO_SUCCESS
        lat = geo_coding_results[0].latlon[0]
        lng = geo_coding_results[0].latlon[1]
      end
      @map.center_zoom_init([lat,lng],1)
    else
      @map.center_zoom_init([@geo_location.lat,@geo_location.lng],15)  	  
    end
    
    session[:geo_location] =  @geo_location
     
    @map.record_init('create_draggable_editable_marker();') ;
    @map.set_map_type_init(GMapType::G_HYBRID_MAP)      
    
    
    @markers = []
    locations = GeoLocation.find(:all)
    locations.each do |location|
      marker = GMarker.new([location.lat, location.lng], :icon => icon_standard, :title => location.name)  
      @markers << marker
      @map.overlay_init marker
    end
  end

  
  def find_location
    results = Geocoding::get(params[:geo_code])
    @latlon = nil
    @map    = Variable.new("map")
    if results.status == Geocoding::GEO_SUCCESS
      @address = results[0].address
      @latlon  = results[0].latlon
    end
  end



  def add_new_marker
    @lng    = params[:pointx]
    @lat    = params[:pointy]
    @map    = Variable.new("map") 
    icon_standard = Variable.new("icon_standard")
    
    @marker = GMarker.new([@lat, @lng],:title => "new location") 
    
    @geo_location     = GeoLocation.new
    @geo_location.lat = @lat
    @geo_location.lng = @lng
    if(session[:geo_location] == nil || find_location_in_db(session[:geo_location].lat, session[:geo_location].lng))
      @geo_location.name        = "[Click To Edit location name]"
      @geo_location.description = "[Provide a brief description, directions, local parking regulations, best season to visit, etc... ]"
    else
      @geo_location.name        = session[:geo_location].name
      @geo_location.description = session[:geo_location].description
    end
    
    session[:geo_location] = @geo_location
    @marker = GMarker.new([@geo_location.lat,@geo_location.lng])

    @markers = []
    locations = GeoLocation.find(:all)
    locations.each do |location|
      marker = GMarker.new([location.lat, location.lng], :icon => icon_standard , :title => location.name )  
      @markers << marker
    end
  end

  def select_marker
    @lng    = params[:pointx] 
    @lat    = params[:pointy]
    @map    = Variable.new("map") 
    icon_standard = Variable.new("icon_standard")
    @geo_location     = find_location_in_db(@lat, @lng)
    @marker = GMarker.new([@geo_location.lat,@geo_location.lng])
    
    session[:geo_location] = @geo_location  
    # @map.center_zoom_init([@geo_location.lat,@geo_location.lng],15)         
    @markers = []
    locations = GeoLocation.find(:all)
    locations.each do |location|
      marker = GMarker.new([location.lat, location.lng], :icon => icon_standard, :title => location.name)  
      unless location.lat == @geo_location.lat && location.lng == @geo_location.lng
        @markers << marker
      end
    end    
  end



  def save
    if params[:commit] == "Save"

      @geo_location = session[:geo_location]      
      
      
      @geo_location.save
      @cleaning_event = CleaningEvent.find(params[:cleaning_event_id])
      @cleaning_event.geo_location = @geo_location
      @cleaning_event.save
      
      session[:geo_location] = nil        
      render :text => '<script type="text/javascript">window.opener.location.reload(true);window.close();</script>'        
    end
    
    if params[:commit] == "Cancel"
      session[:geo_location] = nil        
      render :text => '<script type="text/javascript">window.opener.location.reload(true);window.close();</script>'              
    end
  end
  
private 
  def find_location_in_db(lat, lng)
    locations = GeoLocation.find(:all,
    :conditions => ["lat - 0.00000000001 <= :lat and lat + 0.00000000001 >= :lat 
                and lng - 0.00000000001 <= :lng and lng + 0.00000000001 >= :lng", {:lat => lat.to_f, :lng => lng.to_f}]
                )
    locations[0]
  end
end