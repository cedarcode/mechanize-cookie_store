module Mechanize::CookieStore
  module CookieJar

    def save
      each do |cookie|
        ::Mechanize::CookieStore::Redis.save(cookie)
      end
    end

    def load(options = {})
      ::Mechanize::CookieStore::Redis.all(options).each do |cookie|
        add(cookie)
      end
    end

  end
end

class Mechanize::CookieJar
  prepend Mechanize::CookieStore::CookieJar
end
