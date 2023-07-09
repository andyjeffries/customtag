if defined?(Rails::Railtie)
  module CustomTag
    class Railtie < Rails::Railtie
      initializer do |app|
        app.middleware.use Middleware
      end
    end
  end
end
