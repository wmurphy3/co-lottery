class UpgradesController < ApplicationController
  layout "not_authorized"
  skip_before_action :authenticate_user!

  def show
  end
end