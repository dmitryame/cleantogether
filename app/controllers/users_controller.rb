class UsersController < ApplicationController  
  #Filter method to enforce a login requirement
  before_filter :login_required, :only => [:change_password]

  def events
    if logged_in?
      redirect_to user_cleaning_events_path(current_user) 
    else
      store_location
      redirect_to login_path
    end
  end

  def profile
    if logged_in?
      redirect_to edit_user_path(current_user) 
    end
    store_location
    redirect_to login_path 
  end

  # render new.rhtml
  def new
    logger.debug "empty new method"
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    @user.save
    if @user.errors.empty?
      self.current_user = @user
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end

  def activate
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end




  #
  #change user passowrd
  def change_password
    return unless request.post?
    if User.authenticate(current_user.login, params[:old_password])
      if ((params[:password] == params[:password_confirmation]) && !params[:password_confirmation].blank?)
        current_user.password_confirmation = params[:password_confirmation]
        current_user.password = params[:password]

        if current_user.save
          flash[:notice] = "Password successfully updated" 
          redirect_to profile_url(current_user.login)
        else
          flash[:alert] = "Password not changed" 
        end

      else
        flash[:alert] = "New Password mismatch" 
        @old_password = params[:old_password]
      end
    else
      flash[:alert] = "Old password incorrect" 
    end
  end

  #
  #gain email address
  def forgot_password
    return unless request.post?
    if @user = User.find_by_email(params[:user][:email])
      @user.forgot_password
      @user.save
      redirect_back_or_default('/')
      flash[:notice] = "A password reset link has been sent to your email address" 
    else
      flash[:alert] = "Could not find a user with that email address" 
    end
  end

  #
  #reset password
  def reset_password
    @user = User.find_by_password_reset_code(params[:id])
    #raise if @user.nil?

    return if @user unless params[:user]

    if ((params[:user][:password]  == params[:user][:password_confirmation]) && !params[:user][:password_confirmation].blank?)
      #if (params[:user][:password]  params[:user][:password_confirmation])
      self.current_user = @user #for the next two lines to work
      current_user.password_confirmation = params[:user][:password_confirmation]
      current_user.password = params[:user][:password]
      @user.reset_password
      flash[:notice] = current_user.save ? "Password reset" : "Password not reset"
      redirect_back_or_default(’/’)
    else
      flash[:alert] = "Password mismatch"
    end  




  rescue
    logger.error "Invalid Reset Code entered" 
    flash[:alert] = "That is an invalid password reset code. Please check your code and try again." 
    redirect_back_or_default('/')
  end

end
