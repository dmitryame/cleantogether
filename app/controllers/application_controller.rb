class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :init_current_user


  private
  def init_current_user
    @current_user = FacebookUser.find(session[:user_id]) if session[:user_id]
  end  

  def authorize
    if session[:user_id] == nil
      session[:return_to] = request.request_uri
      redirect_to auth_start_path
    end
  end
end

# ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
# :pretty => "%b %d, %Y",
# :date_time12 => "%m/%d/%Y %I:%M%p",
# :date_time24 => "%m/%d/%Y %H:%M"
# )
# 
