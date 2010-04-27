# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

#require 'rest-open-uri'
#require 'rexml-document'
#require 'net/http'
# require 'net/https'

#require 'uri'

class ApplicationController < ActionController::Base  
  before_filter :init_current_user
    
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  filter_parameter_logging "password"   
  
  
  
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

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
        :pretty => "%b %d, %Y",
        :date_time12 => "%m/%d/%Y %I:%M%p",
        :date_time24 => "%m/%d/%Y %H:%M"
      )
