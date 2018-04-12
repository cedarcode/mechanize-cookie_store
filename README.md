# Mechanize::CookieStore

[![Build Status](https://travis-ci.org/cedarcode/mechanize-cookie_store.svg?branch=master)](https://travis-ci.org/cedarcode/mechanize-cookie_store)

mechanize-cookie_store is an extension to [Mechanize gem](https://github.com/sparklemotion/mechanize) that allow you to persist the Mechanize agent cookie set, in a smarter way than serialized or plain files in the server's system. This allows you to share your cookies across multiple server instances, among other benefits.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mechanize-cookie_store'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mechanize-cookie_store

## Configuration

For *Rails* applications you can create `config/initializers/mechanize-cookie_store.rb` and provide the necessary
configuration params to access your desired persistance method.

If your not using Rails, you just need to make sure to run the same configuration code before using Mechanize.

Please see below the available built-in stores and their specific configurations:

***Currently, the only supported store is Redis.***

### For Redis

```ruby
Mechanize::CookieStore.configure do |config|
  config.connection_params = {
    url: "your-redis-url",
    namespace: "your-redis-namespace" # optional
  }
end
```

- `url` must have a valid redis server url
- `namespace` parameter is optional, default namespace is `mechanize_cookies`


## Usage

After configuring it, usage looks pretty similar to the way you would use
mechanize without this gem.

Instantiate a mechanize session and use it:

```ruby
agent = Mechanize.new

agent.get("https://www.google.com")
```


Then `save` or`load` your cookie_jar the same way you would do it without `mechanize-cookie_store`.

```ruby
agent.cookie_jar.save # to persist cookies to storage

agent.cookie_jar.load # to load back back into the agent from storage
```

Or use if you want to load specific cookie set you can pass to `load` the options
`domain`, `path` and `name` like this:

```ruby
agent.cookie_jar.load(domain: "example.com", path: "/mypath", name: "myCookie")
```

Please note, that these options correpond to the fields of the [HTTP::Cookie](https://github.com/sparklemotion/http-cookie/blob/v1.0.3/lib/http/cookie.rb#L27) class, an inherited dependency from Mechanize.


## Dependencies

This gem depends on:

- [Mechanize](https://github.com/sparklemotion/mechanize)
- [Redis Namespace](https://github.com/resque/redis-namespace)

## Contributing

1. Fork it ( https://github.com/cedarcode/mechanize=cookie_store/ )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

To run the test suite, make sure you have Redis server running in `localhost:6379`. Then just run `bundle exec rake`

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Mechanize::CookieStore project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/cedarcode/mechanize-cookie_store/blob/master/CODE_OF_CONDUCT.md).
