require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users

  def test_crud
      dmitry = users(:dmitry)
      dmitry.password = "dmitry1234"

      assert dmitry.save
      dmitry.reload

      hashed_password = dmitry.hashed_password

      assert_equal hashed_password, dmitry.hashed_password

      assert dmitry.destroy
    end
    
    def test_user_lists
      dmitry = users(:dmitry)
    end
end
