require "redis-namespace"

class Mechanize::CookieStore::Redis

    DEFAULT_NAMESPACE = "mechanize_cookies".freeze

    def self.connection
      return @store_connection if @store_connection

      namespace = Mechanize::CookieStore.connection_params[:namespace] || DEFAULT_NAMESPACE
      redis_connection  = ::Redis.new(Mechanize::CookieStore.connection_params)

      @store_connection = ::Redis::Namespace.new(namespace, redis: redis_connection)
    end

    def self.all(options = {})
      normalized_keys(options).each_with_object([]) do |key, cookies|
        serialized_cookie = connection.get(key)

        if serialized_cookie
          cookie = Marshal.load(serialized_cookie)

          unless cookie_expired?(cookie)
            cookies << cookie
          end
        end
      end
    end

    def self.save(cookie)
      return if cookie_expired?(cookie)

      key = "#{cookie.domain}:#{cookie.path}:#{cookie.name}"

      connection.set(key, Marshal.dump(cookie)) == "OK"
    end

    def self.cookie_expired?(cookie)
      cookie.expires && cookie.expires < Time.now.utc ||
        cookie.created_at && cookie.max_age &&
        cookie.created_at + cookie.max_age < Time.now.utc
    end

    def self.normalized_keys(options = {})
      domain = options[:domain] || "*"
      path   = options[:path]   || "*"
      name   = options[:name]   || "*"

      connection.keys("#{domain}:#{path}:#{name}")
    end

end
