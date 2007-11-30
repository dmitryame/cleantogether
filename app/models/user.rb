require 'digest/sha1'


class User < ActiveRecord::Base
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

