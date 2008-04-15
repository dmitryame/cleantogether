require 'open-uri'

class UserController < ApplicationController
  before_filter :check_authentication, :except => [:signin, :register]
  
  def index
    if request.post?
      @user = User.find(params[:id])
      @user.update_attributes(params[:user])
    else
      @user = User.find(session[:user_id])    
    end
  end
  
  def signin
    if request.post?
      user = User.authenticate(params[:login], params[:password])      
      answer = params[:captcha]
      answer  = answer.gsub(/\W/, '')
      openUrl = open("http://captchator.com/captcha/check_answer/ctgthr_#{params[:session_id].to_i}/#{answer}").read.to_i
      
      if user.blank? || openUrl == 0
        session[:user_id] = nil
        flash[:notice] = "try again";
      else
        post_login(user)
      end
    else
      session[:user_id] = nil
    end
  end
  
  def logout
    reset_session 
    redirect_to :action => "index", :controller => "home"
  end  
  
  def register
    @user = User.new(params[:user])
    
    if request.post? 
      answer = params[:captcha]
      answer  = answer.gsub(/\W/, '')
      openUrl = open("http://captchator.com/captcha/check_answer/ctgthr_r#{params[:session_id].to_i}/#{answer}").read.to_i
      if openUrl == 0
        flash.now[:notice] = "try again"
        return
      end
      if @user.save
        flash.now[:notice] = "User #{@user.login} created"
        post_login @user
      end
    end
  end
  
  private
  
  def post_login(user)
    if user.preallowed_id == nil
      user.add_to_preallowed 
    end  

    
    session[:user_id] = user.id
    session[:user_login] = user.login
    session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
    session[:redirect_to] = nil        
  end     
end
