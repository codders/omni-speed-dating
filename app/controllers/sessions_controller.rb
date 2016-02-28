class SessionsController < ApplicationController

  skip_before_filter :authenticate_user!, :only => [ :create ]
  skip_before_filter :verify_authenticity_token, :only => [ :create ]

  def create
    return permission_denied unless auth_hash
    user = User.find_or_create_from_auth_hash(auth_hash)
    self.current_user = user
    redirect_to '/'
  end

  protected

  def permission_denied
    render :file => "public/401.html", :status => :unauthorized
  end
end
