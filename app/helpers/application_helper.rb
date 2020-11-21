module ApplicationHelper
  def button(name, bot)
    button_player = ""
    if name == "OPEN NEW GIFT" || (@game.user_turn? && !bot)
      button_player = "button-player-red"
    elsif name == "DECIDING..."
      button_player = "button-player-blue"
    elsif name == "STOLEN"
      button_player = "button-player-white"
    elsif name == "STEAL"
      button_player = "button-player-green"
    end
    button_player
  end

  def player_background(game)
    background = "background-green"

    if game[:action] == "STOLEN"
      background = "background-card-yellow"
    elsif game[:bot] && game[:finished]
      background = "background-white"
    elsif game[:action] == "DECIDING..."
      background = "background-blue"
    elsif game[:bot]
      background = "background-pattern"
    end
    background
  end
end
