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
        # here lets send a request to preallowed to figure out the preallowed_id for this user account and stick it in the session.
        url = URI.parse("https://www.preallowed.com/clients/" + CLIENT_ID + "/subjects/id_from_name/" + user.login)
        logger.debug url.path
        
        req = Net::HTTP::Post.new(url.path)
        req.basic_auth PREALLOWED_LOGIN, PREALLOWED_PASSWORD

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        res = http.start {|http| http.request(req) }

        case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          loger.debug "subject:" + :login + " --> id:" + res.body
          session[:preallowed_id] = res.body
        else
          logger.debug "does not exist"
          #TODO:
          #lets create an account in preallowed with the default ACL's
        end
        
        # if the user does not exist in preallowed.com system, create a new one with the default ACL
        session[:user_id] = user.id
        session[:user_login] = user.login
        session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
        session[:redirect_to] = nil        
      end
    else
      session[:user_id] = nil
    end
  end
  
  def logout
    session[:preallowed_id]  = GUEST_SUBJECT_ID #default subject id maps to guest subject
    reset_session 
    redirect_to :action => "index", :controller => "home"
  end  
  
  def register
    @user = User.new(params[:user])
    
    if request.post? 
      answer = params[:captcha]
      answer  = answer.gsub(/\W/, '')
      openUrl = open("http://captchator.com/captcha/check_answer/ctgthr_r#{params[:session_id].to_i}/#{answer}").read.to_i
# debugger
      if openUrl == 0
        flash.now[:notice] = "try again"
        return
      end
      if @user.save
        session[:user_id] = @user.id
        session[:user_login] = @user.login
        flash.now[:notice] = "User #{@user.login} created"
        redirect_to :action => "index", :controller => "home"
      end
    end
  end
 
end
