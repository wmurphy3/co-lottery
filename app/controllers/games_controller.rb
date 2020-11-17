class GamesController < ApplicationController
  before_action :setup_game, only: [:index, :get_next, :steal]
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

  def steal
    @prize = @game.steal
  end

  def entered
    @user   = User.find(params[:id])
    @prize  = @user.prizes.last
  end

  private

  def setup_game
    @game     = Game.new({ip_address: request.remote_ip, prize_id: params[:id]})
    @new_game = @game.setup_game

    if @game.stop_game?
      @prize = @game.winner_prize
    end
  end

  def redirect_to_present
    if @game.finished?
      redirect_to game_path(@game.winner_prize_id)
    end
  end
end