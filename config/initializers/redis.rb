$redis = Redis.new(host: 'localhost', port: 6379, driver: :hiredis)
# $redis = Redis.new(host: Settings.url[:url], port: 6379, driver: :hiredis)