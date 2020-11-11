class Game

  attr_accessor :ip, :failed, :users, :prizes, :game, :cache
  
  # TODO Do we need to clear expired caches?
  def initialize(options={})
    digest  = cache_key(@ip, Date.today)
    @key    = "lottery/#{digest}"

    @cache  = Rails.cache
  end

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

  def get_next
    prize = @game.detect {|f| !f[:finished] }
    prize[:finished] = true
    @game[prize[:id]] = prize
    cache.write(@key, @game, expires_in: 24.hours)

    prize
  end

  def failed?
    failed
  end

  def finished?
    game && game[:finished]
  end

  private

  def get_random_user_list 
    @users = user_list.sample(5).insert(rand(5), {name: "You", bot: false})
  end

  def get_prizes
    @prizes = Prize.all.shuffle.first(6)
  end

  def set_prizes
    users.each_with_index do |u, i| 
      u[:prize]     = {id: prizes[i].id, name: prizes[i].name}
      u[:finished]  = false
      u[:id]        = i
    end
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

  def cache_key(*key)
    Digest::MD5.hexdigest(key.join(''))
  end

end