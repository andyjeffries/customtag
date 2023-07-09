module CustomTag
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      code, headers, response = @app.call(env)

      response[0] = CustomTag.parse_and_replace(response[0]) if headers["Content-Type"]&.include?("text/html")

      [code, headers, response]
    end
  end
end
