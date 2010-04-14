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

  # def ssl_required?
  #  unless RAILS_ENV == 'production'
  #    false
  #  else
  #    super
  #  end
  # end

  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_cleantogether_session_id'
  
    

end

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
        :pretty => "%b %d, %Y",
        :date_time12 => "%m/%d/%Y %I:%M%p",
        :date_time24 => "%m/%d/%Y %H:%M"
      )
