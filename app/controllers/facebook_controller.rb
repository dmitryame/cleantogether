class FacebookController < ApplicationController
  # ensure_application_is_installed_by_facebook_user
  # ensure_authenticated_to_facebook
  
  def index
    @total_collected = Story.collected
  end
end
