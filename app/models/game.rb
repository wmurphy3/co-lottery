class Game

  attr_accessor :ip, :failed, :users, :prizes, :game, :cache
  
  # TODO Do we need to clear expired caches?
  def initialize(options={})
    digest  = cache_key(@ip, Date.today)
    @key    = "lottery/#{digest}"

    @cache  = Rails.cache
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
      prize = get_next_present
      update_game(prize)
      
      prize
    rescue => e
      puts "e: #{e.inspect}"
      @failed = true
    end 
  end

  def steal
    # TODO Figure out bots prize after user steals
  end

  # Check if anything failed
  def failed?
    failed
  end

  # Has 6 prizes been given out? Then it's the last turn
  def finished?
    game && @game.count { |h| h[:finished] == true } == 6
  end

  # Stop game and let user decide
  def stop_game?
    finished? || user_turn?
  end

  # Find the users prize
  def winner_prize
    @game.detect {|f| !f[:bot] }[:prize][:id]
  end

  private

  # Get 5 random bots
  def get_random_user_list 
    @users = user_list.sample(5).insert(rand(5), {name: "You", bot: false})
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
      u[:action]    = i == 0 ? (u[:bot] ? "Deciding..." : "OPEN NEW GIFT" ) :nil
      u[:id]        = i
    end
  end

  # Detect next hash to pull
  def get_next_present
    @game.detect {|f| !f[:finished] }
  end

  # Update game array and cache it
  def update_game(prize)
    action = bot_action

    if action == "open"
      prize[:finished]  = true
      prize[:action]    = "Opened"
      @game[prize[:id]] = prize
    elsif action == "steal_bot"
      # Grab random index from array where finished
      index               = rand(finished_count)
      # Swap current bot gift to stolen bot
      bot_prize           = @game[index]
      bot_prize[:action]  = "Stolen"
      prize[:action]      = "Deciding..."
      @game[prize[:id]]   = bot_prize
      @game[index]        = prize
    else
      # Grab index of user from array
      index               = @game.find_index{ |item| !item[:bot]}
      # Swap current bot with user gift
      bot_prize           = @game[index]
      bot_prize[:action]  = "Stolen"
      prize[:action]      = "Deciding..."
      @game[prize[:id]]   = bot_prize
      @game[index]        = prize
    end

    cache.write(@key, @game, expires_in: 24.hours)
  end

  def user_turn?
    @game.find_index{ |item| !item[:bot]} == @game.count { |h| h[:finished] == true }
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

    if @game.count { |h| h[:finished] == false} < 1
      max_open          = 100
    elsif @game.count { |h| h[:finished] == false && h[:bot] == false } < 1 
      max_open          = 75
      min_steal_bot     = 76
      max_steal_bot     = 100
    end

    case rand(100) + 1
      when 1..max_open   then 'open'
      when min_steal_bot..max_steal_bot   then 'steal_bot'
      when 90..100  then 'steal_player'
    end
  end

end