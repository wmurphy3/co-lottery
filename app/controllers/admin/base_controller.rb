class Admin::BaseController < ActionController::Base
  before_action :check_for_lockup
end
