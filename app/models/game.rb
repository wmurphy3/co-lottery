class Game

  attr_accessor :ip, :failed, :users, :prizes, :game, :cache, :prize_id
  
  # TODO Do we need to clear expired caches?
  def initialize(options={})
    digest    = cache_key(options[:ip_address], Date.today)
    @key      = "lottery/#{digest}"
    @prize_id = options[:prize_id]
    @cache    = Rails.cache
  end

  # Find or create a new game with 5 bots and the user
  # This includes marking bot: boolean, prize: string, name: string
  def setup_game
    begin
      @game = @cache.fetch(@key, expires_in: 24.hours) do
        get_random_user_list 
        get_prizes
        set_prizes
      end
    rescue => e
      puts "e: #{e.inspect}"
      @failed = true
    end 
  end

  # Get next prize
  def get_next
    begin
      puts "@game: #{@game}"
      prize = get_next_present
      prize = update_game(prize)
      puts "@game: #{@game}"
      prize
    rescue => e
      puts "e: #{e.inspect}"
      @failed = true
    end 
  end

  def steal
    begin
      # Get prizes
      prize                 = winner_prize
      bot_prize             = @game[@prize_id.to_i]
      # Set action
      bot_prize[:action]    = "DECIDING..."
      prize[:action]        = "STOLEN"
      # swap prizes
      temp_prize            = prize[:prize]
      prize[:prize]         = bot_prize[:prize]
      bot_prize[:prize]     = temp_prize
      # set status
      prize[:finished]      = true
      bot_prize[:finished]  = false

      if final_turn?
        prize[:final] = true
      end
      
      # set game
      @game[prize[:id]]     = prize
      @game[@prize_id.to_i] = bot_prize

      cache.write(@key, @game, expires_in: 24.hours)

      bot_prize
    rescue => e
      puts "e: #{e.inspect}"
      @failed = true
    end 
  end

  # Check if anything failed
  def failed?
    failed
  end

  # Has 6 prizes been given out? Then it's the last turn
  def finished?
    game && game.count { |h| h[:finished] == true && h[:final] } == 6
  end

  # Stop game and let user decide
  def stop_game?
    finished? || user_turn?
  end

  # Find the users prize
  def winner_prize_id
    @game.detect {|f| !f[:bot] }[:prize][:id]
  end

  def winner_prize
    @game.detect {|f| !f[:bot] }
  end

  def last_turn?
    game && !finished? && game.count { |h| h[:finished] == true } == 6
  end

  private

  # Get 5 random bots
  def get_random_user_list 
    @users = user_list.sample(5).insert(0, {name: "Me", bot: false})
  end

  # Get 6 random prizes
  def get_prizes
    @prizes = Prize.all.shuffle.first(6)
  end

  # Set the prize json
  def set_prizes
    users.each_with_index do |u, i| 
      u[:prize]     = {id: prizes[i].id, name: prizes[i].name}
      u[:finished]  = false
      u[:final]     = i == 0 ? false : true
      u[:action]    = i == 0 ? (u[:bot] ? "DECIDING..." : "OPEN NEW GIFT" ) :nil
      u[:id]        = i
    end
  end

  # Detect next hash to pull
  def get_next_present
    if last_turn?
      @game.detect {|f| !f[:final] }
    else
      @game.detect {|f| !f[:finished] }
    end
  end

  # Update game array and cache it
  def update_game(prize)
    action = bot_action

    if last_turn?
      prize[:final]  = true
      prize[:action]    = "OPENED"
      @game[prize[:id]] = prize
    elsif action == "open"
      prize[:finished]  = true
      prize[:action]    = "OPENED"
      @game[prize[:id]] = prize
    elsif action == "steal_bot"
      # Grab random index from array where finished
      index                 = rand(finished_count)
      bot_prize             = @game[index]
      #set action
      prize[:action]        = "STOLEN"
      bot_prize[:action]    = "DECIDING..."
      #swap prizes
      temp_prize            = prize[:prize]
      prize[:prize]         = bot_prize[:prize]
      bot_prize[:prize]     = temp_prize
      # set status
      prize[:finished]      = true
      bot_prize[:finished]  = false
      #set game
      @game[prize[:id]]     = prize
      @game[index]          = bot_prize

      prize = bot_prize
    else
      # Grab index of user from array
      index                 = @game.find_index{ |item| !item[:bot]}
      bot_prize             = @game[index]
      #set action
      prize[:action]        = "STOLEN"
      bot_prize[:action]    = "DECIDING..."
      #swap prizes
      temp_prize            = prize[:prize]
      prize[:prize]         = bot_prize[:prize]
      bot_prize[:prize]     = temp_prize
      # set status
      prize[:finished]      = true
      bot_prize[:finished]  = false
      #set game
      @game[prize[:id]]     = prize
      @game[index]          = bot_prize

      prize = bot_prize
    end

    cache.write(@key, @game, expires_in: 24.hours)
    prize
  end

  def user_turn?
    turn_num  = @game.count { |h| h[:finished] == true }
    user_turn = @game.find_index{ |item| !item[:bot]}
    turn_num == user_turn || 
      (turn_num > user_turn && @game.count{ |item| !item[:bot] && !item[:finished]} > 0) ||
        (turn_num == 6 && user_turn == 0)
  end

  def cache_key(*key)
    Digest::MD5.hexdigest(key.join(''))
  end

  def user_list
    [
      {name: "John Doe", bot: true},
      {name: "Jane Doe", bot: true},
      {name: "Test User", bot: true},
      {name: "User Test", bot: true},
      {name: "John Doe", bot: true},
      {name: "Jane Doe", bot: true},
      {name: "Test User", bot: true},
      {name: "User Test", bot: true},
      {name: "John Doe", bot: true},
      {name: "Jane Doe", bot: true},
      {name: "Test User", bot: true},
      {name: "User Test", bot: true}
    ]
  end

  def finished_count
    @finished_count ||= @game.count { |h| h[:finished] == true}
  end

  def bot_action
    max_open          = 65
    min_steal_bot     = 66
    max_steal_bot     = 89
    min_steal_player  = 90
    max_steal_player  = 100
    num               = rand(100) + 1

    if @game.count { |h| h[:finished] == true} < 1 || user_turn? || last_turn?
      max_open          = 100
    elsif @game.count { |h| h[:finished] == true && h[:bot] == false } < 1 
      max_open          = 75
      min_steal_bot     = 76
      max_steal_bot     = 100
    end
    
    case num
      when 1..max_open                  then 'open'
      when min_steal_bot..max_steal_bot then 'steal_bot'
      when 90..100                      then 'steal_player'
    end
  end

end