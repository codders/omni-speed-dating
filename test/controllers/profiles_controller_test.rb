require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase

  test "should redirect to home page unless logged in" do
    get :show
    assert_redirected_to "/auth/developer"
  end

  test "should load profile page" do
    logged_in_as :dummy
    get :show
    assert_response :success
  end

  test "should load edit page" do
    logged_in_as :dummy
    get :edit
    assert_response :success
  end

  test "should update profile" do
    logged_in_as :dummy
    post :create, { gender: "male" }
    assert_redirected_to profile_path
  end

end
