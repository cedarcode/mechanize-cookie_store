require "mechanize"
require "mechanize/cookie_store/cookie_jar"
require "mechanize/cookie_store/redis"

module Mechanize::CookieStore

  class << self

    attr_accessor :connection_params

    def configure
      yield self
    end

  end

end
