require 'digest/sha1'


class OldUser < ActiveRecord::Base
  has_many :pictures


  validates_presence_of     :login, :email
  validates_uniqueness_of   :login

  attr_accessor :password_confirmation
#  validates_confirmation_of :password

  def validate
    errors.add_to_base("Missing password") if hashed_password.blank?
  end


  def self.authenticate(login, password)
    user = self.find_by_login(login)
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    end
    user
  end

  # 'password' is a virtual attribute
  def password
    @password
  end

  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = OldUser.encrypted_password(self.password, self.salt)
  end

  # is a virtual RO attribute that will make a call to preallowed service
  def team_captain
    if is_user_in_role(TEAM_CAPTAIN_ROLE_ID) == "1"
      return true
    else
      return false
    end
  end

  def add_to_preallowed
    self.preallowed_id = OldUser.find_or_create_preallowed_id(self)
    self.save
    OldUser.add_user_to_role(self, GUEST_ROLE_ID)
    OldUser.add_user_to_role(self, USER_ROLE_ID)
  end


  def after_destroy
    if OldUser.count.zero?
      raise "Can't delete last user"
    end
  end     
  
  # preallowed methods that make a service call 

  # return true in case of success, false otherwise
  def self.add_user_to_role(user, role_id)
    url = URI.parse( BASE_URI + "/subjects/" + user.preallowed_id.to_s + "/add_role")
    logger.debug url.path

    req = Net::HTTP::Post.new(url.path)
    req.basic_auth PREALLOWED_LOGIN, PREALLOWED_PASSWORD
    req.set_form_data({'role_id'=> role_id}, ';')

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    res = http.start {|http| http.request(req) } 
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      logger.debug "successfully added preallowed_user to role"
      return true
    else
      logger.error "error adding preallowed_user to role"        
      return false
    end
  end
  
  # return true in case of success, false otherwise
  def self.remove_user_from_role(user, role_id)
    url = URI.parse( BASE_URI + "/subjects/" + user.preallowed_id.to_s + "/remove_role")
    logger.debug url.path

    req = Net::HTTP::Post.new(url.path)
    req.basic_auth PREALLOWED_LOGIN, PREALLOWED_PASSWORD
    req.set_form_data({'role_id'=> role_id}, ';')

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    res = http.start {|http| http.request(req) } 
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      logger.debug "successfully removed preallowed_user from role"
      return true
    else
      logger.error "error removing preallowed_user from role"        
      return false
    end
  end



  # resolve_preallowed_id takes user, returns preallowed_id or nil if not found
  def self.resolve_preallowed_id(user)
    url = URI.parse( BASE_URI + "/subjects/id_from_name/" + user.login)
    logger.debug url.path

    req = Net::HTTP::Get.new(url.path)
    req.basic_auth PREALLOWED_LOGIN, PREALLOWED_PASSWORD

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    res = http.start {|http| http.request(req) }

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection      
      logger.debug "subject:" + user.login + " --> id:" + res.body
      return nil if res.body.to_i == 0 # return nil if the id is 0
      res.body      
    else
      logger.error "does not exist"
      nil
    end
    
  end
  
  #this methods will try to find a subject in preallowed by login, or will create a new one, will return a preallowed_id or nil
  def self.find_or_create_preallowed_id(user)
    # first lets see if such seubject already eixst to avoid dups
    preallowed_id = self.resolve_preallowed_id(user) 
    
    unless preallowed_id == nil
      return preallowed_id
    end
    
    #otherwise create a new one
    url = URI.parse(BASE_URI + "/subjects")

    req = Net::HTTP::Post.new(url.path)
    req.basic_auth PREALLOWED_LOGIN, PREALLOWED_PASSWORD
    req.set_form_data({'subject[name]' => user.login, 'commit' => "Create"}, '&')
    logger.debug("url: " + url.to_s )

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    res = http.start {|http| http.request(req) }

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      logger.debug "creating preallowed subject succsess!!!!!!!!!!!!!!!!!!!!! " + user.login 
      logger.debug res.body      
      return self.resolve_preallowed_id(user) # now that the subject created in the preallowed system, have to get it's id
    else
      flash[:notice] =    "failed creating preallowed subject !!!!!!!!!!!!!!!!!!!! " + user.login      
      logger.error "error adding new preallowed_user to default guest role"      
      nil
    end
    
  end

  def is_user_in_role(role_id)
    url = URI.parse(BASE_URI + "/subjects/" + preallowed_id.to_s + "/is_subject_in_role/" + role_id)

    req = Net::HTTP::Get.new(url.path)
    req.basic_auth PREALLOWED_LOGIN, PREALLOWED_PASSWORD
    logger.debug("url: " + url.to_s )

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    res = http.start {|http| http.request(req) }

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      logger.debug res.body      
      return res.body
    else
      logger.error "error in is_subject_in_role web service call"
    end
    "0"    
  end


  #how much user collected 
  def collected
    CleaningEvent.sum 'weight', :conditions => ["user_id = ?", id]
  end

  def number_of_events
    CleaningEvent.count :conditions => ["user_id = ?", id]
  end


  private

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end

end

