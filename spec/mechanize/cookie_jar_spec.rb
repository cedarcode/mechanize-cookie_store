require 'mechanize'

RSpec.describe Mechanize::CookieJar do
  let(:agent) { Mechanize.new }

  describe "#save" do
    it "uses the gem store's save method" do
      mock_cookie = HTTP::Cookie.new(name: "dummy", domain: "dummy", path: "dumy", expires: Time.now + 60)
      agent.cookie_jar.add(mock_cookie)

      expect(Mechanize::CookieStore::Store::Redis).to receive(:save).with(mock_cookie)

      agent.cookie_jar.save
    end
  end

  describe "#load" do
    it "uses the gem store's load method" do
      expect(Mechanize::CookieStore::Store::Redis).to receive(:all).and_return([])

      agent.cookie_jar.load
    end
  end

end
