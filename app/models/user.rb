require 'digest/sha1'
class User < ActiveRecord::Base
  has_many :stories
  
  has_many :captains_teams,
  :foreign_key => "captain_id",
  :class_name => "Team"
  
  has_many :captains_expeditions,
  :foreign_key => "captain_id",
  :class_name => "Expedition",
  :order => "target_date DESC"

  has_and_belongs_to_many :teams

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 6..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_format_of       :email, :with => /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i

  before_save :encrypt_password
  before_create :make_activation_code 
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :first_name, :last_name

  class ActivationCodeNotFound < StandardError; end
  class AlreadyActivated < StandardError
    attr_reader :user, :message;
    def initialize(user, message=nil)
      @message, @user = message, user
    end
  end
    
  # Finds the user with the corresponding activation code, activates their account and returns the user.
  #
  # Raises:
  #  +User::ActivationCodeNotFound+ if there is no user with the corresponding activation code
  #  +User::AlreadyActivated+ if the user with the corresponding activation code has already activated their account
  def self.find_and_activate!(activation_code)
    raise ArgumentError if activation_code.nil?
    user = find_by_activation_code(activation_code)
    raise ActivationCodeNotFound if !user
    raise AlreadyActivated.new(user) if user.active?
    user.send(:activate!)
    user
  end  
    
  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Returns true if the user has just been activated.
    def pending?
      @activated
    end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  #
  def forgot_password
    @forgotten_password = true
    self.make_password_reset_code
  end

  #
  #
  def reset_password
    # First update the password_reset_code before setting the 
    # reset_password flag to avoid duplicate email notifications.
    update_attributes(:password_reset_code => nil)
    @reset_password = true
  end  

  #
  #used in user_observer
  def recently_forgot_password?
    @forgotten_password
  end
  
  def recently_reset_password?
    @reset_password
  end
  
  def self.find_for_forget(email)
    find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email]
  end
  
  
  # is a virtual RO attribute that will make a call to preallowed service
  def team_captain
    if is_user_in_role(TEAM_CAPTAIN_ROLE_ID) == "1"
      return true
    else
      return false
    end
  end
  # preallowed methods that make a service call 
  def admin
    if is_user_in_role(ADMIN_ROLE_ID) == "1"
      return true
    else
      return false
    end
  end

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


  def add_to_preallowed
    self.preallowed_id = User.find_or_create_preallowed_id(self)
    self.save
    User.add_user_to_role(self, GUEST_ROLE_ID)
    User.add_user_to_role(self, USER_ROLE_ID)
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
      logger.error "error adding new preallowed_user to default guest role"      
      nil
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


  #how much user collected 
  def collected
    Story.sum 'weight', :conditions => ["user_id = ?", id]
  end

  def number_of_events
    Story.count :conditions => ["user_id = ?", id]
  end

  protected
  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    crypted_password.blank? || !password.blank?
  end

  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  # same as make_activation_code
  def make_password_reset_code
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
  
  private

  def activate!
    @activated = true
    self.update_attribute(:activated_at, Time.now.utc)
  end
  
end
