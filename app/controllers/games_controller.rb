class GamesController < ApplicationController
  before_action :setup_game

  def index
    # TODO if failed show a screen/alert?
  end

  def show
    @prize = @game[params[:id].to_i]
    # TODO set value in redis, incase somebody refreshes
  end

  private

  def setup_game
    game = Game.new({ip_address: request.remote_ip})
    @game = game.setup_game
  end
end