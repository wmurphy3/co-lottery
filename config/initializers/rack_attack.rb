class Rack::Attack

  ### Configure Cache ###

  # If you don't want to use Rails.cache (Rack::Attack's default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blacklisting and
  # whitelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  ### Throttle Spammy Clients ###
  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!
  #
  # Note: If you're serving assets through rack, those requests may be
  # counted by rack-attack and this throttle may be activated too
  # quickly. If so, enable the condition to exclude them from tracking.

  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle('req/ip', :limit => 300, :period => 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  Rack::Attack.safelist('allow from localhost') do |req|
    '67.198.44.149' == req.ip
  end

  blocklist('block wp routes and 404js malware') do |req|
    req.path.include?('404javascript') ||
    req.path.include?('wp-admin') ||
    req.path.include?('wp-login')
  end

  blocklist("block all access to boot") do |req|
    req.path.include?('boot.ini')
  end

  blocklist("block all access using %") do |req|
    req.path == '/%'
  end

  blocklist("block all passwd attempts") do |req|
    req.path.include?('etc/passwd')
  end

  blocklist("block all non http methods") do |req|
    %w[OPTIONS GET HEAD POST PUT DELETE TRACE CONNECT PROPFIND PROPPATCH MKCOL COPY MOVE LOCK
      UNLOCK {} REPORT CHECKOUT CHECKIN UNCHECKOUT MKWORKSPACE UPDATE LABEL MERGE {} MKACTIVITY
      ORDERPATCH ACL SEARCH MKCALENDAR PATCH].exclude?(req.request_method)
  end

  blocklist("block all mobile attempts") do |req|
    req.path.include?('mobile')
  end

  ### Prevent Brute-Force Login Attacks ###

  # The most common brute-force login attack is a brute-force password
  # attack where an attacker simply tries a large number of emails and
  # passwords to see if any credentials match.
  #
  # Another common method of attack is to use a swarm of computers with
  # different IPs to try brute-forcing a password for a specific account.

  # Throttle POST requests to /login by IP address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
  # Throttle POST requests to /login by email param
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{req.email}"
  #
  # Note: This creates a problem where a malicious user could intentionally
  # throttle logins for another user and force their login requests to be
  # denied, but that's not very common and shouldn't happen to you. (Knock
  # on wood!)

  ### Custom Throttle Response ###

  # By default, Rack::Attack returns an HTTP 429 for throttled responses,
  # which is just fine.
  #
  # If you want to return 503 so that the attacker might be fooled into
  # believing that they've successfully broken your app (or you just want to
  # customize the response), then uncomment these lines.
  # self.throttled_response = lambda do |env|
  #  [ 503,  # status
  #    {},   # headers
  #    ['']] # body
  # end
end
