require 'mechanize'

RSpec.describe Mechanize::CookieJar do
  let(:agent) { Mechanize.new }

  it "uses the gem store's save method" do
    expect(agent.cookie_jar.save).to eq("Saved with mechanize-cookie_store")
  end

  it "uses the gem store's load method" do
    expect(agent.cookie_jar.load).to eq("Loaded with mechanize-cookie_store")
  end
end
