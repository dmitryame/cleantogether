require File.dirname(__FILE__) + '/../test_helper'
require 'user_controller'

# Re-raise errors caught by the controller.
class UserController; def rescue_action(e) raise e end; end

class UserControllerTest < Test::Unit::TestCase
  
  fixtures :users
  
  def setup
    @controller = UserController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # def test_signin
  #   dmitry                        =  users(:dmitry)
  #   post :signin, :login => dmitry.login, :password => "dmitry1234"
  #   assert_equal dmitry.id, session[:user_id]
  # end
  
  
  # def test_bad_password
  #   dmitry = users(:dmitry)
  #   post :signin, :login => dmitry.login, :password => 'wrong'
  #   assert_template "signin"
  # end
  
#  def test_register
#    post :register, :login => "aaa123", :password => "aaa", :password_confirmation => "aaa", :email => "asd@qwe.com"
#    assert_not_equal nil, session[:user]
#  end
def test_true
  assert true
end  

end
