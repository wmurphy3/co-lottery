class UsersController < ApplicationController
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
    params.require(:user).permit(:first_name, :last_name, :address, :email, :phone, :prize_id)
  end
end