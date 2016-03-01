require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  test "should redirect to home page if logged in" do
    logged_in_as :dummy
    get :landing
    assert_redirected_to "/home"
  end

  test "should get logged-in page" do
    logged_in_as :dummy
    get :index
    assert_response :success
  end

  test "logged-in page should include logout link" do
    logged_in_as :dummy
    get :index
    assert_response :success
    assert_select "a#logout", "Logout"
  end

  test "logged-in page should include user's name" do
    logged_in_as :dummy
    get :index
    assert_response :success
    assert_select "a#logout", "Logout"
    assert_select "span#username", users(:dummy).name
  end

  test "should redirect to landing page from home page if not logged in" do
    get :index
    assert_redirected_to '/auth/developer'
  end

  test "should get landing page" do
    get :landing
    assert_response :success
  end

  test "logged out page should include login link" do
    get :landing
    assert_response :success
    assert_select "a#login", "Login"
  end

end
