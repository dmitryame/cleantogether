class AuthorizeController < ApplicationController
  def start
    redirect_to OAuthClient.web_server.authorize_url(
      :redirect_uri => auth_callback_url,
      :scope => 'email,offline_access,publish_stream'
    )
  end

  def callback
    access_token = OAuthClient.web_server.get_access_token(
      params[:code], :redirect_uri => auth_callback_url
    )
    @current_user = FacebookUser.create_from_fb(access_token)    
    session[:user_id] = @current_user.id
    if(session[:return_to])
      redirect_to session[:return_to] 
    else
      redirect_to :home        
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to :home    
  end
  
end
