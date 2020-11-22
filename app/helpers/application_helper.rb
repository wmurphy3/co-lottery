module ApplicationHelper
  def button(name, bot)
    button_player = ""
    if name == "OPEN NEW GIFT" || (@game.user_turn? && !bot)
      button_player = "button-player-red"
    elsif name == "DECIDING..."
      button_player = "button-player-blue"
    elsif name == "STOLEN"
      button_player = "button-player-white"
    elsif name == "STEAL" || (@game.user_turn? && bot && !@game.first_turn?)
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

  def action_name(g)
    name = ""
    if g[:action] != "OPENED"
      if g[:action] == "DECIDING..."
        name = "DECIDING<span>.</span><span>.</span><span>.</span>".html_safe
      elsif @game.user_turn? && g[:bot] && !@game.first_turn?
        name = "STEAL"
      else
        name = g[:action] ? g[:action] : (@game.stop_game? && !@game.finished? && !g[:bot] ? "OPEN NEW GIFT" : "")
      end
    elsif @game.user_turn? && g[:bot]
      name = "STEAL"
    end
    name
  end
end
