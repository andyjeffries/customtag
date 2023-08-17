require "spec_helper"
require "rack"

class MiddlewareReplace < CustomTag::Base
  register :replace, self

  def self.build(_, attrs, content)
    attrs["class"] = "text-red-500 #{attrs["class"]}".strip
    super("div", attrs, content)
  end
end

RSpec.describe CustomTag::Middleware do
  it "returns unmolested response if content type is not html" do
    app = ->(env) { [200, {"Content-Type" => "text/plain"}, ["<html><body><replace>me</replace></body></html>"]] }
    middleware = CustomTag::Middleware.new(app)

    expect(middleware.call(env_for("http://example.com"))).to eq([200, {"Content-Type" => "text/plain"}, ["<html><body><replace>me</replace></body></html>"]])
  end

  it "returns returns original body if no replacements made" do
    app = ->(env) { [200, {"Content-Type" => "text/html"}, ["<!DOCTYPE html><html><body><ignore>me</ignore></body></html>"]] }
    middleware = CustomTag::Middleware.new(app)

    expect(middleware.call(env_for("http://example.com"))).to eq([200, {"Content-Length"=>"62", "Content-Type" => "text/html"}, ["<!DOCTYPE html>\n<html><body><ignore>me</ignore></body></html>\n"]])
  end

  it "returns returns original body with replaced tags if found" do
    app = ->(env) { [200, {"Content-Type" => "text/html"}, ["<!DOCTYPE html><html><body><replace>me</replace></body></html>"]] }
    middleware = CustomTag::Middleware.new(app)

    expect(middleware.call(env_for("http://example.com"))).to eq([200, {"Content-Length"=>"77", "Content-Type" => "text/html"}, ["<!DOCTYPE html>\n<html><body><div class=\"text-red-500\">me</div></body></html>\n"]])
  end

  def env_for url, opts={}
    Rack::MockRequest.env_for(url, opts)
  end
end
