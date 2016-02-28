class HomeController < ApplicationController

  skip_before_filter :authenticate_user!, :only => [ :landing, :logout ]
  before_filter      :deauthenticate_user!, :only => [ :logout ]
  before_filter      :authenticate_user, :only => [ :landing ]

  def index
    redirect_to :landing unless logged_in?
  end

  def landing
    redirect_to :home if logged_in?
  end

  def logout
  end

end
