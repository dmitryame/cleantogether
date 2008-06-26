class FacebookerPublisher < Facebooker::Rails::Publisher
  def profile_for_user(user_to_update)
      send_as :profile
      from user_to_update
      recipients user_to_update
      fbml = render(:partial =>"/facebook/user_profile.fbml.erb")
      profile(fbml)
      action =  render(:partial => "/facebook/profile_action.fbml.erb") 
      profile_action(action) 
      session[:facebook_session].user.profile_fbml =  (render_to_string :partial => 'profile')
      
  end
end