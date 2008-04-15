require 'digest/sha1'


class User < ActiveRecord::Base
  has_many :pictures


  validates_presence_of     :login, :email
  validates_uniqueness_of   :login

  attr_accessor :password_confirmation
  validates_confirmation_of :password

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
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end

  def add_to_preallowed
    url = URI.parse(BASE_URI + "/subjects")

    req = Net::HTTP::Post.new(url.path)
    req.basic_auth PREALLOWED_LOGIN, PREALLOWED_PASSWORD
    req.set_form_data({'subject[name]' => self.login, 'commit' => "Create"}, '&')
    logger.debug("url: " + url.to_s )

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    res = http.start {|http| http.request(req) }

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      logger.debug "creating preallowed subject succsess!!!!!!!!!!!!!!!!!!!!! " + self.login 
      logger.debug res.body
    else
      flash[:notice] =    "failed creating preallowed subject !!!!!!!!!!!!!!!!!!!! " + self.login      
      logger.error "error adding new preallowed_user to default guest role"      
    end
    # here lets send a request to preallowed to figure out the preallowed_id for this user account and store it in user
    url = URI.parse( BASE_URI + "/subjects/id_from_name/" + self.login)
    logger.debug url.path

    req = Net::HTTP::Get.new(url.path)
    req.basic_auth PREALLOWED_LOGIN, PREALLOWED_PASSWORD

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    res = http.start {|http| http.request(req) }

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      logger.debug "subject:" + self.login + " --> id:" + res.body
      self.preallowed_id = res.body
      self.save
      
      # lets add a newly created preallowed user to the default guest role with the id 11 (eventually default roles should be configurable in the preallowed)
      url = URI.parse( BASE_URI + "/subjects/" + self.preallowed_id.to_s + "/add_role")
      logger.debug url.path

      req = Net::HTTP::Post.new(url.path)
      req.basic_auth PREALLOWED_LOGIN, PREALLOWED_PASSWORD
      req.set_form_data({'role_id'=> GUEST_ROLE_ID}, ';')

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      res = http.start {|http| http.request(req) } 
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        logger.debug "successfully added new preallowed_user to default geust role"
      else
        logger.error "error adding new preallowed_user to default geust role"        
      end

    else
      logger.error "does not exist"
    end
  end


  def after_destroy
    if User.count.zero?
      raise "Can't delete last user"
    end
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

