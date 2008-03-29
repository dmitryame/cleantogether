# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

#require 'rest-open-uri'
#require 'rexml-document'
#require 'net/http'
require 'net/https'

#require 'uri'

class ApplicationController < ActionController::Base  
  before_filter :check_authorization

  BASE_URI = "https://www.preallowed.com/clients/2"
  SUBJECT  = "4"
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
     puts "???????????????????? authorization ???????????????????????? " + request.request_uri
     url = URI.parse(BASE_URI + "/subjects/" + SUBJECT + "/has_access/")
      
      
     req = Net::HTTP::Post.new(url.path)
     req.basic_auth 'preallowed_admin', 'preallowed_admin'
     req.set_form_data({'reseource'=> request.request_uri}, ';')
     # breakpoint
     
     http = Net::HTTP.new(url.host, url.port)
     http.use_ssl = true
     
     res = http.start {|http| http.request(req) }
     
     case res
     when Net::HTTPSuccess, Net::HTTPRedirection
       puts "succsess!!!!!!!!!!!!!!!!!!!!!"
       puts res.body
     else
       res.error!
     end

  end


end

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
        :pretty => "%b %d, %Y",
        :date_time12 => "%m/%d/%Y %I:%M%p",
        :date_time24 => "%m/%d/%Y %H:%M"
      )
