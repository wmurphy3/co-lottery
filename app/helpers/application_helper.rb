module ApplicationHelper
  def button(name)
    button_player = ""
    if name == "OPEN NEW GIFT"
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
end
