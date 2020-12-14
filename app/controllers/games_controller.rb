class GamesController < ApplicationController
  before_action :setup_game, only: [:index, :get_next, :steal]
  before_action :redirect_to_present, only: [:index]
  #before_action :get_cookie, only: [:show]

  layout "modal", only: [:entered, :show]

  def index
  end

  def show
    @prize = Prize.find(decrypted_id)
  end

  def get_next
    @prize = @game.get_next
  end

  def steal
    @prize = @game.steal
  end

  def entered
    @user   = User.find(decrypted_id)
    @prize  = @user.prizes.order('user_prizes.id').last
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
      cookie = cookies[:white_elephant]

      if cookie.blank?
        redirect_to game_path(encrypted_id(@game.winner_prize_id))
      else
        decrypted_cookie = Base64.decode64(cookie)

        unless decrypted_cookie.blank? || params[:id].blank?
          if UserPrize.create({
            user_id:  decrypted_cookie,
            prize_id: decrypted_id
          })
            redirect_to entered_game_path(encrypted_id(decrypted_cookie))
          end
        end
      end
    end
  end

  def get_cookie
    cookie = cookies[:white_elephant]

    unless cookie.blank?
      decrypted_cookie = Base64.decode64(cookie)

      unless decrypted_cookie.blank?
        if UserPrize.find_by({
          user_id:  decrypted_cookie,
          prize_id: decrypted_id
        })
          redirect_to entered_game_path(encrypted_id(decrypted_cookie))
        end
      end
    end
  end
end