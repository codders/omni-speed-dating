require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  test "should redirect to 401 if no auth provided" do
    post :create, :provider => "developer"
    assert_response :unauthorized
  end

  test "should load the login page" do
    request.env["omniauth.auth"] = { name: "Dummy", email: "dummy@dummy.org", provider: "developer" }
    post :create, :provider => "developer"
    assert_response 302
    assert_redirected_to '/'
  end

end
