class AuthorizeController < ApplicationController
  def start
    redirect_to OAuthClient.web_server.authorize_url(
      :redirect_uri => auth_callback_url,
      :scope => 'email,offline_access,publish_stream'
    )
  end

  def callback
    access_token = OAuthClient.web_server.access_token(
      params[:code], :redirect_uri => auth_callback_url
    )
    @user = FacebookUser.create_from_fb(access_token)
  end

end
