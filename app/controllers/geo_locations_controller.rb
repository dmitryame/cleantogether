class GeoLocationsController < ApplicationController
  before_filter :login_required
  def new
  	@geo_location = GeoLocation.new
    @map = GMap.new("map")
    @map.control_init(:large_map => true,:map_type => true)
    @map.icon_global_init(GIcon.new(:image => "http://labs.google.com/ridefinder/images/mm_20_green.png", :icon_size => GSize.new(15,15),:icon_anchor => GPoint.new(7,7),:info_window_anchor => GPoint.new(9,2)),"icon_standard")
    icon_standard = Variable.new("icon_standard")
    
    @map.center_zoom_init([0,0],1)
         
    @map.record_init('create_draggable_editable_marker();') ;
    @map.set_map_type_init(GMapType::G_HYBRID_MAP)      
    
    
    # @markers = []
    # locations = GeoLocation.find(:all)
    # locations.each do |location|
    #   marker = GMarker.new([location.lat, location.lng], :icon => icon_standard, :title => location.name)  
    #   @markers << marker
    #   @map.overlay_init marker
    # end
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

    # @markers = []
    # locations = GeoLocation.find(:all)
    # locations.each do |location|
    #   marker = GMarker.new([location.lat, location.lng], :icon => icon_standard , :title => location.name )  
    #   @markers << marker
    # end
  end


  def create
    @geo_location = GeoLocation.new(params[:geo_location])
    
    if params[:commit] == "Save new Location"
      if @geo_location.save
        redirect_to :controller => "cleaning_events", :action => "new", :geo_location_id => @geo_location
      else
        if (@geo_location.lat == nil && @geo_location.lng == nil) || (@geo_location.lat == 0 && @geo_location.lng == 0)
          flash[:error] = "Set a marker by clicking on the map" 
        end        
        
        if flash[:error] == nil 
          flash[:error] = "Oops, something went wrong, correct the errors below and resubmit..." 
        end
        @map = GMap.new("map")
        @map.control_init(:large_map => true,:map_type => true)
        @map.icon_global_init(GIcon.new(:image => "http://labs.google.com/ridefinder/images/mm_20_green.png", :icon_size => GSize.new(15,15),:icon_anchor => GPoint.new(7,7),:info_window_anchor => GPoint.new(9,2)),"icon_standard")
        icon_standard = Variable.new("icon_standard")

        @map.center_zoom_init(@geo_location,1)

        @map.record_init('create_draggable_editable_marker();') ;
        @map.set_map_type_init(GMapType::G_HYBRID_MAP)      
        
        render :action => "new"
      end
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