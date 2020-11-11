class GamesController < ApplicationController
  before_action :setup_game

  def index
    # TODO if failed/finished show a screen/alert?
    puts "@new_game: #{@new_game}"
  end

  def get_next
    @prize = @game.get_next
  end

  private

  def setup_game
    @game = Game.new({ip_address: request.remote_ip})
    @new_game = @game.setup_game
  end
end