# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base  
  before_filter :check_authorization
  
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_cleantogether_session_id'
  
  def check_authentication
    puts "!!!!!!!!!!!!!!!!!!!! authentication !!!!!!!!!!!!!!!!!!!!!!! " + request.request_uri
    
    unless session[:user_id]
      session[:return_to] = request.request_uri
      flash[:notice] =    "Please log in"      
      redirect_to :controller => "user", :action => "signin"
    end
  end    
  
  def check_authorization
    # now, that the request is authenticated, let's see if it's authorized as well
     puts "???????????????????? authorization ???????????????????????? " + request.request_uri
  end


end

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
        :pretty => "%b %d, %Y",
        :date_time12 => "%m/%d/%Y %I:%M%p",
        :date_time24 => "%m/%d/%Y %H:%M"
      )
