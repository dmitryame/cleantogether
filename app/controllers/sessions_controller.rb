# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  before_filter :login_required, :only => :destroy
  
  ssl_required :new
  
  
  #   before_filter :not_logged_in_required, :only => [:new, :create]
  # render new.rhtml
  def new
  end

  def create
    password_authentication(params[:login], params[:password])
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to login_path    
  end



  # Updated 2/20/08
  def password_authentication(login, password)
    user = User.authenticate(login, password)
    if user == nil
      failed_login("Your username or password is incorrect.")
    elsif user.activated_at.blank?  
      failed_login("Your account is not active, please check your email for the activation code.")
    elsif user.enabled == false
      failed_login("Your account has been disabled.")
    else
      self.current_user = user
      successful_login
    end
  end

  private

  def failed_login(message)
    flash.now[:error] = message
    render :action => 'new'
  end

  def successful_login
    if params[:remember_me] == "1"
      self.current_user.remember_me
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
    end
    flash[:notice] = "Logged in successfully"
    return_to = session[:return_to]
    
    # check preallowed_id and resolve if necessery
    current_user.add_to_preallowed if current_user.preallowed_id == nil

    if return_to.nil?
      redirect_to home_path
    else
      redirect_to return_to
    end
  end
  
  
end
