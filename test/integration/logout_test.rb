require 'test_helper'

class LogoutTest < ActionDispatch::IntegrationTest

  test "logout should clear session" do
    # Login
    dummy = users(:dummy)
    post "/auth/developer/callback", name: dummy.name, email: dummy.email
    assert_redirected_to '/'
    assert_equal dummy.email, session['current_user']

    # Logout
    get "/logout"
    assert_redirected_to '/'
    assert_nil session['current_user']
  end

end
