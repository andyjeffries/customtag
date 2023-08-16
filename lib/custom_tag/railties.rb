if defined?(Rails::Railtie)
  module CustomTag
    class Railtie < Rails::Railtie
      initializer "custom_tag.configure_rails_installation" do |app|
        app.middleware.use Middleware
      end
    end
  end
end
