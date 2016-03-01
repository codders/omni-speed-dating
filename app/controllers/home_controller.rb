class HomeController < ApplicationController

  skip_before_filter :authenticate_user!, :only => [ :landing, :logout ]
  before_filter      :deauthenticate_user!, :only => [ :logout ]
  before_filter      :authenticate_user, :only => [ :landing ]

  def index
    redirect_to :landing unless logged_in?
  end

  def landing
    if logged_in?
      redirect_to :home
    else
      render :layout => "landing"
    end
  end

  def logout
  end

end
