class FacebookController < ApplicationController
  ensure_authenticated_to_facebook
  ensure_application_is_installed_by_facebook_user
  
  def index
    @total_collected = Story.collected
  end
end
