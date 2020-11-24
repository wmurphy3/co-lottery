module ApplicationHelper
  def custom_bootstrap_flash
    flash_messages = []
    flash.each do |type, message|
      puts "type: #{type} message: #{message}"
      return if message.blank? || message.is_a?(TrueClass) || message.is_a?(FalseClass)
      message = message.map{|k,v| "<b>#{k.to_s.humanize}</b>: #{escape_javascript(v[0])}"}.join('<br>').html_safe if !message.kind_of? String
      type = 'success' if type == 'notice'
      type = 'error'   if type == 'alert'
      if type == 'success'
        @text = "<script>toastr.#{type}('#{message}','Success');</script>"
      else
        @text = "<script>toastr.#{type}('#{message}','Error', {timeOut: 0, extendedTimeOut: 0});</script>"
      end
      flash_messages << @text.html_safe if message
    end

    flash_messages.join("\n").html_safe
  end
  
  def button(name, bot, finished)
    button_player = ""
    if name == "OPEN NEW GIFT" || (@game.user_turn? && !bot)
      button_player = "button-player-red"
    elsif name == "DECIDING..."
      button_player = "button-player-blue"
    elsif name == "STEAL" || (@game.user_turn? && bot && !@game.first_turn? && finished)
      button_player = "button-player-green"
    elsif name == "STOLEN"
      button_player = "button-player-white"
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
      elsif @game.user_turn? && g[:bot] && !@game.first_turn? && g[:finished]
        name = "STEAL"
      else
        name = g[:action] ? g[:action] : (@game.stop_game? && !@game.finished? && !g[:bot] ? "OPEN NEW GIFT" : "")
      end
    elsif @game.user_turn? && g[:bot] && g[:finished]
      name = "STEAL"
    elsif @game.user_turn? && !g[:bot] && @game.last_turn?
      name = "KEEP"
    end
    name
  end

  def class_name(g)
    button = button(g[:action], g[:bot], g[:finished])
    c = g[:finished] ? g[:prize][:class_name] : g[:gift]
    c += " no-banner" if button.blank?
    c
  end

  def indefinite_articlerize(params_word)
    %w(n).include?(params_word[0].downcase) ? 
      params_word : 
        %w(a e i o u).include?(params_word[0].downcase) ? 
          "An #{params_word}" : "A #{params_word}"
  end
end
