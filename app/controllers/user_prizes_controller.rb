class UserPrizesController < ApplicationController
  after_action :set_cookie
  
  def create
    @user = UserPrize.new(user_params)

    if @user.save
      redirect_to entered_game_path(encrypted_id(@user.user_id))
    else
      flash[:error] = @user.errors.messages
      render :new
    end
  end

  private

  def user_params
    params.require(:user_prize).permit(:email, :prize_id)
  end

  def set_cookie
    if @user.user_id && @user.persisted?
      cookies[:white_elephant] = { value: Base64.encode64(@user.user_id.to_s), expires: 1.month.from_now}
    end
  end
end