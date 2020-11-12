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

  # Check if anything failed
  def failed?
    failed
  end

  # Has 6 prizes been given out? Then it's the last turn
  def finished?
    game && @game.count { |h| h[:finished] == true } == 6
  end

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
      u[:id]        = i
    end
  end

  # detect next hash to pull
  def get_next_present
    @game.detect {|f| !f[:finished] }
  end

  # Update game array and cache it
  def update_game(prize)
    prize[:finished] = true
    @game[prize[:id]] = prize
    cache.write(@key, @game, expires_in: 24.hours)
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

end