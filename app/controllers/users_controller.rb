class UsersController < ApplicationController
  after_action :set_cookie

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to entered_game_path(@user.id)
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :address, :email, :phone, :prize_id, :remember_me)
  end

  def set_cookie
    if user_params[:remember_me] && @user.id
      cookies[:white_elephant] = { value: Base64.encode64(@user.id.to_s, expires: 1.month.from_now}
    end
  end
end