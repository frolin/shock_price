require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ShokPrice
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.read_encrypted_secrets = (Rails.env == 'production')
    config.time_zone = "Moscow"
    config.active_record.default_timezone = :utc
    # config.eager_load_paths << Rails.root.join("extras")
    config.i18n.default_locale = :ru
    config.autoload_paths << "#{Rails.root}/app/processes"
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
