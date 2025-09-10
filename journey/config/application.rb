require_relative "boot"
require "rails/all"
Bundler.require(*Rails.groups)

module Journey
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])
    config.i18n.available_locales = %i[en de]
    config.i18n.default_locale = :en
  end
end
