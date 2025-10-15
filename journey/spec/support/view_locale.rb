RSpec.configure do |config|
  config.before(type: :view) do
    I18n.with_locale = I18n.locale.presence || I18n.default_locale
  end
end
