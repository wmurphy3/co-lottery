class UserPrizesController < ApplicationController

  def create
    @user = UserPrize.new(user_params)

    if @user.save
      redirect_to entered_game_path(@user.user_id)
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user_prize).permit(:email, :prize_id)
  end
end