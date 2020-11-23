class Game
  attr_accessor :ip, :failed, :users, :prizes, :game, :cache, :prize_id

  UNOPENED_GIFTS = %w(red-gift yellow-gift green-gift)
  
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
      prize = get_next_present
      prize = update_game(prize)
    
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

      if last_turn?
        prize[:final]         = true
        bot_prize[:action]    = "OPENED"
        bot_prize[:finished]  = true
      else
        bot_prize[:finished]  = false
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

  def first_turn?
    game && game.count { |h| h[:finished] == false } == 6
  end

  def current_user
    return nil if finished?

    if last_turn?
      name = @game.detect {|f| !f[:final] }[:name]
    else
      name = @game.detect {|f| !f[:finished] }[:name]
    end

    name = name == "ME" ? "your" : name

    "It's #{name} turn..."
  end

  def user_turn?
    turn_num  = @game.count { |h| h[:finished] == true }
    user_turn = @game.find_index{ |item| !item[:bot]}
    turn_num == user_turn || 
      (turn_num > user_turn && @game.count{ |item| !item[:bot] && !item[:finished]} > 0) ||
        (turn_num == 6 && user_turn == 0)
  end

  private

  # Get 5 random bots
  def get_random_user_list 
    @users = user_list.sample(5).insert(rand(5), {name: "ME", bot: false})
  end

  # Get 6 random prizes
  def get_prizes
    @prizes = Prize.all.shuffle.first(6)
  end

  # Set the prize json
  def set_prizes
    users.each_with_index do |u, i| 
      u[:prize]     = {id: prizes[i].id, name: prizes[i].name, class_name: prizes[i].class_name}
      u[:finished]  = false
      u[:gift]      = UNOPENED_GIFTS[rand(3)]
      u[:final]     = i == 0 ? false : true
      u[:action]    = i == 0 ? (u[:bot] ? "DECIDING..." : "OPEN NEW GIFT" ) :nil
      u[:id]        = i
      u[:stolen]    = false
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
      prize[:final]     = true
      prize[:action]    = "OPENED"
      prize[:stolen]    = false
      @game[prize[:id]] = prize
    elsif action == "open"
      prize[:finished]  = true
      prize[:action]    = "OPENED"
      prize[:stolen]    = false
      @game[prize[:id]] = prize
    elsif action == "steal_bot"
      # Grab random index from array where finished
      random                = [*0..finished_count - 1]
      random                = random - [winner_prize[:id]] if winner_prize[:id] < finished_count
      index                 = random.sample
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
      prize[:stolen]        = false
      bot_prize[:stolen]    = true
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
      prize[:stolen]        = false
      bot_prize[:stolen]    = true
      #set game
      @game[prize[:id]]     = prize
      @game[index]          = bot_prize

      prize = bot_prize
    end

    cache.write(@key, @game, expires_in: 24.hours)
    prize
  end

  def cache_key(*key)
    Digest::MD5.hexdigest(key.join(''))
  end

  def user_list
    [
      {name: "Mitchmonster7", bot: true},
      {name: "T0p1cal", bot: true},
      {name: "Roserivera", bot: true},
      {name: "Notimelikenow3", bot: true},
      {name: "Stulich08", bot: true},
      {name: "Gobroncos777", bot: true},
      {name: "Fancygirl25", bot: true},
      {name: "J1nglebe11s", bot: true},
      {name: "Kriskringle22", bot: true},
      {name: "Falalalala10", bot: true},
      {name: "Elfman732", bot: true},
      {name: "Thesantaclaus", bot: true},
      {name: "Coloradical48", bot: true},
      {name: "Xmasisthebest", bot: true},
      {name: "Sidseymour", bot: true},
      {name: "Tpacker99", bot: true},
      {name: "Scottstots", bot: true},
      {name: "Rockiesrule17", bot: true},
      {name: "Avsfanatic19", bot: true},
      {name: "Naughtyornice1", bot: true},
      {name: "Nuggets4l1fe", bot: true},
      {name: "Ilikeicecream9", bot: true},
      {name: "Davidfosterwallet", bot: true},
      {name: "Peter.mcall8", bot: true},
      {name: "Crazy4elves", bot: true},
      {name: "Dancergirl23", bot: true},
      {name: "Fastguy9", bot: true},
      {name: "Scrooge4", bot: true},
      {name: "Mntnboy104", bot: true},
      {name: "Jchillin87", bot: true},
      {name: "Janlevg23", bot: true},
      {name: "Coolronamintz", bot: true},
      {name: "Coloradoclaus3", bot: true},
      {name: "Dwitch55", bot: true},
      {name: "Gpolinski1", bot: true},
      {name: "Froggy101", bot: true},
      {name: "Pizzafanatic6", bot: true},
      {name: "Iheartxmas9", bot: true},
      {name: "Franzenj3", bot: true},
      {name: "Zeeezy8", bot: true},
      {name: "Yeahyeaht", bot: true},
      {name: "Vivi46", bot: true},
      {name: "C0stanza", bot: true},
      {name: "Hepennypacker", bot: true},
      {name: "Avandalay66 ", bot: true},
      {name: "Sourcreambarly1", bot: true},
      {name: "Mistermonkeydog", bot: true},
      {name: "ColoradoChillGirl", bot: true},
      {name: "Trout1992", bot: true},
      {name: "BreckBro89", bot: true},
      {name: "Dawgwalker9000", bot: true},
      {name: "PicklesDaFrenchie", bot: true},
      {name: "ToddyBahama", bot: true},
      {name: "PonchoinDenver", bot: true},
      {name: "Clowndarkmatter", bot: true},
      {name: "hashtagSanta", bot: true},
      {name: "no2stunna", bot: true},
      {name: "littlemissmuffin", bot: true},
      {name: "mountainjunoswan", bot: true},
      {name: "hotdogpants", bot: true},
      {name: "mountainturkey", bot: true},
      {name: "mrsrobot", bot: true},
      {name: "honeybunny", bot: true},
      {name: "password123", bot: true},
      {name: "pwned126", bot: true},
      {name: "amber1977", bot: true},
      {name: "MDouggie", bot: true},
      {name: "MuricaMan", bot: true},
      {name: "FlatEarthDonna", bot: true},
      {name: "GarfieldFanArt", bot: true},
      {name: "PowerDaze", bot: true},
      {name: "TonyRichardson15", bot: true},
      {name: "Rebeccasunrise", bot: true},
      {name: "Savannah_Hope", bot: true},
      {name: "MsMaggieKate", bot: true},
      {name: "DevinneysRevenge", bot: true},
      {name: "SantosLHalper", bot: true},
      {name: "Anniehallmonitor", bot: true},
      {name: "Insomniac400", bot: true},
      {name: "Leetspeak337", bot: true},
      {name: "THISISBEANS", bot: true},
      {name: "AndysCandies", bot: true},
      {name: "GladiatorBee", bot: true},
      {name: "Dougspectacular", bot: true},
      {name: "BitcoinBaller", bot: true},
      {name: "BeefSalad", bot: true},
      {name: "ElleorysRealDad", bot: true},
      {name: "BoobiliPizzaMan", bot: true},
      {name: "JBBoulder19", bot: true}
    ]
  end

  def finished_count
    @finished_count ||= @game.count { |h| h[:finished] == true}
  end

  def bot_action
    max_open          = 84
    min_steal_bot     = 85
    max_steal_bot     = 97
    num               = rand(100) + 1

    if @game.count { |h| h[:finished] == true && h[:bot] == true} < 2 || user_turn? || last_turn?
      max_open          = 100
    elsif @game.count { |h| h[:finished] == true && h[:bot] == false } < 1 
      max_steal_bot     = 100
    end
    puts "num: #{num}"
    case num
      when 1..max_open                  then 'open'
      when min_steal_bot..max_steal_bot then 'steal_bot'
      when 98..100                      then 'steal_player'
    end
  end

end