
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "mechanize/cookie_store/version"

Gem::Specification.new do |spec|
  spec.name          = "mechanize-cookie_store"
  spec.version       = Mechanize::CookieStore::VERSION
  spec.authors       = ["Braulio Martinez"]
  spec.email         = ["braulio@cedarcode.com"]

  spec.summary       = "A Mechanize extension that allows cookies to be saved in more advanced stores than serialized filesystem files."
  spec.homepage      = "https://github.com/cedarcode/mechanize-cookie_store"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "mechanize", "~> 2.7"
  spec.add_dependency "redis-namespace", "~> 1.6"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "byebug"
end
