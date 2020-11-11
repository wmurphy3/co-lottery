class Redis
	REDIS_SERVER = ENV['REDIS_URL'] || "redis://localhost:6379/0/cache"

  def self.cache
    ActiveSupport::Cache.lookup_store(driver: :hiredis, url: REDIS_SERVER)
  end
end