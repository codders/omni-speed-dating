require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  test "should redirect to 401 if no auth provided" do
    post :create, :provider => "developer"
    assert_response :unauthorized
  end

  test "should load the login page" do
    request.env["omniauth.auth"] = { name: "Dummy", uid: "dummy@dummy.org", provider: "developer" }
    post :create, :provider => "developer"
    assert_response 302
    assert_redirected_to '/'
  end

  test "should create a new user if missing" do
    users = User.all.size
    request.env["omniauth.auth"] = { name: "Bob", uid: "bob@dummy.org", provider: "developer" }
    post :create, :provider => "developer"
    assert_response 302
    assert_redirected_to '/'
    assert_equal users + 1, User.all.size, "Should have created a new user"
    assert_equal session["current_user"].uid, "bob@dummy.org", "Expected user to be added to session"
  end

  test "should load existing user if present" do
    users = User.all.size
    existing_user = User.find_by_name("Dummy")
    request.env["omniauth.auth"] = { name: existing_user.name, uid: existing_user.uid, provider: "developer" }
    post :create, :provider => "developer"
    assert_response 302
    assert_redirected_to '/'
    assert_equal users, User.all.size, "Should not have created a new user" 
    assert_equal session["current_user"].uid, existing_user.uid, "Expected user to be added to session"
  end

  test "should save facebook username, email" do
    request.env["omniauth.auth"] = { uid: "12345", 
                                     provider: "facebook",
                                     info: {
                                       email: "dummy@facebook.com",
                                       name: "Mark Zuckerberg" 
                                     }
                                   }
    post :create, :provider => "facebook"
    assert_response 302
    assert_redirected_to '/'
    created = User.last
    assert_equal created.name, "Mark Zuckerberg", "Name should be saved"
    assert_equal created.email, "dummy@facebook.com", "Email should be saved"
  end

end
