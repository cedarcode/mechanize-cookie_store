module Mechanize::CookieStore
  module CookieJar

    def save
      each do |cookie|
        ::Mechanize::CookieStore::Store::Redis.save(cookie)
      end
    end

    def load(options = {})
      ::Mechanize::CookieStore::Store::Redis.all(options).each do |cookie|
        add(cookie)
      end
    end

  end
end

class Mechanize::CookieJar
  prepend Mechanize::CookieStore::CookieJar
end
