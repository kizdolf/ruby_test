require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get view" do
    get :view
    assert_response :success
  end

  test "should get intra" do
    get :intra
    assert_response :success
  end

  test "should get dash" do
    get :dash
    assert_response :success
  end

end
