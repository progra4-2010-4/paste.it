require 'test_helper'

class VersionsControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get compare" do
    get :compare
    assert_response :success
  end

end
