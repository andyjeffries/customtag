module CustomTag
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      code, headers, response = @app.call(env)

      unless headers["Content-Type"]&.include?("text/html")
        return [code, headers, response]
      end

      response_body = if response.respond_to?(:body)
        response.body
      else
        response[0]
      end

      response_body = CustomTag.parse_and_replace(response_body)

      headers["Content-Length"] = response_body.bytesize.to_s
      [code, headers, [response_body]]
    end
  end
end
