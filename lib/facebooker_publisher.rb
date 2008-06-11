class FacebookerPublisher < Facebooker::Rails::Publisher
  def profile_for_user(user_to_update)
      send_as :profile
      from user_to_update
      recipients user_to_update
      fbml = render :template => "facebook/index"
      profile(fbml)
      # action =  render(:partial => "messaging/profile_action.fbml.erb") 
      # profile_action(action) 
  end
end