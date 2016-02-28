class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

  before_filter :authenticate_user!

  private

  def authenticate_user
    if current_user.nil? and !auth_hash.nil?
      current_user = User.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
    end
  end

  def authenticate_user!
    authenticate_user
    redirect_to "/auth/#{auth_provider}" unless current_user
  end

  def deauthenticate_user!
    session['current_user'] = nil
    @current_user = nil
    redirect_to '/'
  end

  def auth_provider
    Rails.env == "production" ? "facebook" : "developer"
  end
 
  def auth_hash
    request.env["omniauth.auth"]
  end

  def current_user=(user)
    @current_user = user
    session['current_user'] = @current_user
  end

  def current_user
    @current_user ||= session['current_user']
  end

  def logged_in?
    return !current_user.nil?
  end
end
