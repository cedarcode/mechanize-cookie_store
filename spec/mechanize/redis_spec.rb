RSpec.describe Mechanize::CookieStore::Redis do
  SECONDS_OF_DAY =  24 * 60 * 60

  let(:agent) { Mechanize.new }

  let(:one_day_ago)      { Time.now - SECONDS_OF_DAY }
  let(:one_day_from_now) { Time.now + SECONDS_OF_DAY }

  let(:connection_params) { { url: "redis://localhost:6379/0" } }

  before do
    allow(Mechanize::CookieStore).to receive(:connection_params).and_return(connection_params)
  end

  after do
    connection = Redis.new(connection_params)
    connection.flushall
  end

  describe "#connection" do
    it "uses a default namespace if it's not provided" do
      expect(::Redis::Namespace).to receive(:new).with("mechanize_cookies", anything)

      described_class.connection
    end

    it "instantiates redis connection only once" do
      con_1 = described_class.connection
      con_2 = described_class.connection

      expect(con_1.object_id).to eq(con_2.object_id)
    end
  end

  describe "#save" do
    it "doesn't save the cookie if it's expired" do
      cookie = HTTP::Cookie.new(name: "dummy", domain: "dummy.test", path: "/dummy", expires: one_day_ago)
      described_class.save(cookie)

      expect(described_class.connection.keys("*")).to be_empty
    end

    it "saves the cookie successfully" do
      cookie = HTTP::Cookie.new(name: "dummy", domain: "dummy.test", path: "/dummy", expires: one_day_from_now)
      described_class.save(cookie)
      found_keys = described_class.connection.keys("*")

      expect(found_keys).not_to be_empty
      expect(found_keys.count).to eq(1)
      expect(found_keys.first).to eq("dummy.test:/dummy:dummy")
    end
  end

  describe "#all" do
    it "doesn't return expired cookies" do
      cookie = HTTP::Cookie.new(name: "dummy", domain: "dummy.test", path: "/dummy", expires: one_day_ago)
      described_class.connection.set("dummy.test:/dummy:dummy", Marshal.dump(cookie))

      expect(described_class.all).to be_empty
    end

    it "returns all cookies that match criteria passed in options" do
      cookie_1 = HTTP::Cookie.new(name: "cookie_1", domain: "dummy.test", path: "/dummy", expires: one_day_from_now)
      described_class.connection.set("dummy:dummy:cookie_1", Marshal.dump(cookie_1))

      cookie_2 = HTTP::Cookie.new(name: "cookie_2", domain: "dummy.test", path: "/dummy", expires: one_day_from_now)
      described_class.connection.set("dummy:dummy:cookie_2", Marshal.dump(cookie_2))

      result = described_class.all(name: "cookie_2")

      expect(result).not_to be_empty
      expect(result.count).to eq(1)
      expect(result.first).to eq(cookie_2)
    end

  end

  describe "#cookie_expired?" do
    it "answers true if expire field is in the past" do
      cookie = HTTP::Cookie.new(name: "dummy", domain: "dummy.test", path: "/dummy", expires: one_day_ago)

      expect(described_class.cookie_expired?(cookie)).to be_truthy
    end

    it "answers false if expire field is in the future" do
      cookie = HTTP::Cookie.new(name: "dummy", domain: "dummy.test", path: "/dummy", expires: one_day_from_now)

      expect(described_class.cookie_expired?(cookie)).to be_falsy
    end

    it "answers true if max_age from creation is in the past" do
      cookie = HTTP::Cookie.new(name: "dummy", domain: "dummy.test", path: "/dummy", max_age: 60, created_at: one_day_ago)

      expect(described_class.cookie_expired?(cookie)).to be_truthy
    end

    it "answers false if max_age from creation is in the future" do
      cookie = HTTP::Cookie.new(name: "dummy", domain: "dummy.test", path: "/dummy", max_age: 60, created_at: one_day_from_now)

      expect(described_class.cookie_expired?(cookie)).to be_falsy
    end
  end

  describe "#normalized_keys" do
    let(:cookie)       { HTTP::Cookie.new(name: "cookie", domain: "domain_1", path: "path_1", expires: one_day_from_now) }
    let(:other_cookie) { HTTP::Cookie.new(name: "other_cookie", domain: "domain_2", path: "path_2", expires: one_day_from_now) }

    before do
      described_class.connection.set("domain_1:path_1:cookie", Marshal.dump(cookie))

      described_class.connection.set("domain_2:path_2:other_cookie", Marshal.dump(other_cookie))
    end

    it "returns keys that matched domain" do
      options = { domain: "domain_1" }

      expect(described_class.normalized_keys(options)).to contain_exactly("domain_1:path_1:cookie")
    end

    it "returns keys that matched path" do
      options = { path: "path_1" }

      expect(described_class.normalized_keys(options)).to contain_exactly("domain_1:path_1:cookie")
    end

    it "returns keys that matched name" do
      options = { name: "cookie" }

      expect(described_class.normalized_keys(options)).to contain_exactly("domain_1:path_1:cookie")
    end

    it "returns keys for all domains, paths and names if no option is provided" do
      expect(described_class.normalized_keys).to contain_exactly("domain_1:path_1:cookie", "domain_2:path_2:other_cookie")
    end
  end

end
