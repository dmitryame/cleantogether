class UsersController < ApplicationController  
  ssl_required :new
  
  
  #Filter method to enforce a login requirement
  before_filter :login_required, :except => [:events, :profile, :new, :create, :activate, :enable, :forgot_password, :reset_password]
  before_filter :initialize_to_current_user

  
  def stories
    if logged_in?
      redirect_to user_stories_path(current_user) 
    else
      store_location
      redirect_to login_path
    end
  end

  def profile
    if logged_in?
      redirect_to user_path(current_user) 
    else
      store_location
      redirect_to login_path 
    end
  end

  # render new.rhtml
  def new
    @user = User.new
  end

  #This show action only allows users to view their own profile
  def show
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
      #we don't want to log in newly regestered user, the user has to activate the account first
      #self.current_user = @user
      flash[:notice] = "Thanks for signing up! Check your email for activation link."
      redirect_to login_path
    else
      flash[:notice] = "Error Creating User."
      render :action => 'new'
    end
  end

  def edit
    if request.post?
      @user.update_attributes(params[:user])
    else
      @user = User.find(session[:user_id])    
    end
  end


  def update
    if @user.update_attributes(params[:user])
        flash[:notice] = "User updated"
        redirect_to user_path(current_user)
      else
        render :action => :edit
      end
  end

  def destroy
    if @user.update_attribute(:enabled, false)
      flash[:notice]      = "User disabled"
    else
      flash[:error]       = "There was a problem disabling this user."
    end
    redirect_to :action   => 'index'
  end

  def enable
    if @user.update_attribute(:enabled, true)
      flash[:notice]      = "User enabled"
    else
      flash[:error]       = "There was a problem enabling this user."
    end
    redirect_to :action   => 'index'
  end



  # Activate action
  def activate
    # Uncomment and change paths to have user logged in after activation - not recommended
    #self.current_user = User.find_and_activate!(params[:id])
    User.find_and_activate!(params[:id])
    flash[:notice] = "Your account has been activated! You can now login."
    redirect_to login_path
  rescue User::ArgumentError
    flash[:notice] = 'Activation code not found. Please try creating a new account.'
    redirect_to new_user_path 
  rescue User::ActivationCodeNotFound
    flash[:notice] = 'Activation code not found. Please try creating a new account.'
    redirect_to new_user_path
  rescue User::AlreadyActivated
    flash[:notice] = 'Your account has already been activated. You can log in below.'
    redirect_to login_path
  end

  # Change password action  
  def change_password
    return unless request.post?
    if User.authenticate(current_user.login, params[:old_password])
      if ((params[:password] == params[:password_confirmation]) && !params[:password_confirmation].blank?)
        current_user.password_confirmation = params[:password_confirmation]
        current_user.password = params[:password]        
        if current_user.save
          flash[:notice] = "Password successfully updated."
          redirect_to root_path #profile_url(current_user.login)
        else
          flash[:error] = "An error occured, your password was not changed."
          render :action => 'edit'
        end
      else
        flash[:error] = "New password does not match the password confirmation."
        @old_password = params[:old_password]
        render :action => 'edit'      
      end
    else
      flash[:error] = "Your old password is incorrect."
      render :action => 'edit'
    end 
  end

  #
  #gain email address
  def forgot_password
    return unless request.post?
    if @user = User.find_by_email(params[:user][:email])
      @user.forgot_password
      @user.save
      flash[:notice] = "A password reset link has been sent to your email address" 
      redirect_to login_path
    else
      flash[:error] = "Could not find a user with that email address" 
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
      redirect_back_or_default('/')
    else
      flash[:error] = "Password mismatch"
    end  

  rescue
    logger.error "Invalid Reset Code entered" 
    flash[:error] = "That is an invalid password reset code. Please check your code and try again." 
    redirect_back_or_default('/')
  end


  def toggle_team_captain
    if @user.team_captain
      User.remove_user_from_role(@user, TEAM_CAPTAIN_ROLE_ID)
    else
      User.add_user_to_role(@user, TEAM_CAPTAIN_ROLE_ID)
    end
  end

private

  def initialize_to_current_user
    @user = current_user
  end
end
