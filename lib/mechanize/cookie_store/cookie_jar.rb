module Mechanize::CookieStore
  module CookieJar

    def save
      "Saved with mechanize-cookie_store"
    end

    def load
      "Loaded with mechanize-cookie_store"
    end

  end
end

class Mechanize::CookieJar
  prepend Mechanize::CookieStore::CookieJar
end
