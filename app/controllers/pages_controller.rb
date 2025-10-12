class PagesController < ApplicationController
  def home
    if logged_in?
      redirect_to dashboard_path
    end
  end
end
