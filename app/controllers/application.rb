# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_cleantogether_session_id'
  
  def check_authentication
    unless session[:user_id]
      session[:return_to] = request.request_uri
      flash[:notice] =    "Please log in"      
      redirect_to :controller => "user", :action => "signin"
    end
  end

end
