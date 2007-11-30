class CleaningController < ApplicationController
  before_filter :check_authentication
 
  in_place_edit_for :cleaning_event, :weigth
  in_place_edit_for :cleaning_event, :blog

  # in_place_editor_filed helper methods
  
  def set_cleaning_event_blog
    @cleaning_event = CleaningEvent.find(params[:id])
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
 
 
 
  def index
    @cleaning_events = CleaningEvent.paginate_by_user_id session[:user_id], :page => params[:page],:per_page => 10, :order => "created_at DESC"
  end
  
  def add_new_cleaning_event  
    @cleaning_event   = CleaningEvent.new(
    :user_id      => session[:user_id],
    :blog  => '[Click me to write up a short BLOG story about the event...]'
    )
    @cleaning_event.cleaning_at = Time.now.to_s(:long)
    @cleaning_event.save
    #@cleaning_events = CleaningEvent.find_all_by_user_id(session[:user_id])    
  end
  
  def delete_cleaning_event
    @removed_cleaning_event_id = params[:id]
    @cleaning_event = CleaningEvent.find(params[:id])
    
    Picture.destroy(@cleaning_event.picture) if @cleaning_event.picture
    CleaningEvent.destroy(@removed_cleaning_event_id)    
  end
  
  def update_cleaning_at
    @cleaning_event = CleaningEvent.find(params[:id])
    @cleaning_event.cleaning_at = params[:cleaning_at]
    @cleaning_event.save
  end
  
  def add_new_geo_location_to_event
  end
  
  

  def upload_picture
    @picture = Picture.create! params[:picture]
      
    @picture.save
    @cleaning_event = CleaningEvent.find(params[:cleaning_event_id])
    @cleaning_event.picture = @picture
    if @cleaning_event.save
      responds_to_parent do
        render :update do |page|
          page.replace "cleaning-event-picture-#{@cleaning_event.id}", :partial => 'cleaning_event_picture', :object => @cleaning_event
          page["cleaning-event-picture-#{@cleaning_event.id}"].visual_effect :pulsate
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
      
    
  def location_editor
    @cleaning_event = CleaningEvent.find(params[:id])
  end
end
