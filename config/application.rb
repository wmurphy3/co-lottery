require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CoLottery
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    config.time_zone = 'Central Time (US & Canada)'
    config.active_record.default_timezone = :local

    config.exception_handler = {
      dev:        true, # allows you to turn ExceptionHandler "on" in development
      db:         nil, # allocates a "table name" into which exceptions are saved (defaults to nil)
      email:      nil, # sends exception emails to a listed email (string // "you@email.com")

      # Custom Exceptions
      custom_exceptions: {
        'ActionController::RoutingError' => :not_found
      },

      # This is an entirely NEW structure for the "layouts" area
      # You're able to define layouts, notifications etc ↴

      # All keys interpolated as strings, so you can use symbols, strings or integers where necessary
      exceptions: {
        404 => {
          layout: "404", # define layout
          notification: false, # (false by default)
          deliver: nil
        },
        406 => {
          layout: "404", # define layout
          notification: false, # (false by default)
          deliver: nil
        },
        500 => {
          layout: "500", # define layout
          notification: false, # (false by default)
          deliver: nil
        },
      }
    }

    # config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
