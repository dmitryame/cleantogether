# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

#require 'rest-open-uri'
#require 'rexml-document'
#require 'net/http'
require 'net/https'

#require 'uri'

class ApplicationController < ActionController::Base  
  include AuthenticatedSystem

  filter_parameter_logging "password" 
  
  include SslRequirement

  def ssl_required?
   unless RAILS_ENV == 'production'
     false
   else
     super
   end
  end

  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_cleantogether_session_id'
  
    
  def check_authorization
    if(@user != nil)
      @user = User.find(session[:user_id]) 
      preallowed_id = @user.preallowed_id 
    else
      preallowed_id = GUEST_SUBJECT_ID
      @user = User.new #guest user is not tied to the database id      
    end

    session[:user_id] = @user.id
    
    logger.debug "???????????????????? authorization ???????????????????????? --> " + request.request_uri
    
    url = URI.parse(BASE_URI + "/subjects/" + preallowed_id.to_s + "/has_access/")

    req = Net::HTTP::Post.new(url.path)
    req.basic_auth PREALLOWED_LOGIN, PREALLOWED_PASSWORD
    req.set_form_data({'resource'=> request.request_uri}, ';')
    logger.debug("url: " + url.to_s )
    logger.debug('resource: ' + request.request_uri)

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    res = http.start {|http| http.request(req) }

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      logger.debug res.body
      response_string = res.body
      if(response_string.to_i == 0)
        redirect_to :controller => "home", :action => "insufficient"
      end
    else
      flash[:notice] =    "Insufficient privileges"      
      logger.error "failed check authorization -- connection problem!!!!"
      redirect_to :controller => "users", :action => "signin"
    end

  end
end

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
        :pretty => "%b %d, %Y",
        :date_time12 => "%m/%d/%Y %I:%M%p",
        :date_time24 => "%m/%d/%Y %H:%M"
      )
