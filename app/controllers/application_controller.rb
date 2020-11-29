class ApplicationController < ActionController::Base
  before_action :check_for_lockup


  private

  def decrypted_id
    Base64.decode64(params[:id])
  end

  def encrypted_id(id)
    URI.escape((Base64.encode64(id.to_s).strip))
  end
end
