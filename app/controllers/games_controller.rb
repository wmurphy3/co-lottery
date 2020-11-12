class GamesController < ApplicationController
  before_action :setup_game, only: [:index, :get_next]
  before_action :redirect_to_present, only: [:index]

  def index
    # TODO if failed/finished show a screen/alert?
  end

  def show
    @prize = Prize.find(params[:id])
  end

  def get_next
    @prize = @game.get_next
  end

  def entered
    @user   = User.find(params[:id])
    @prize  = @user.prizes.last
  end

  private

  def setup_game
    @game     = Game.new({ip_address: request.remote_ip})
    @new_game = @game.setup_game
  end

  def redirect_to_present
    if @game.finished
      redirect_to game_path(@game.winner_prize)
    end
  end
end