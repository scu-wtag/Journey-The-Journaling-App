module LocaleHelpers
  def loc(extra = {})
    { locale: I18n.locale.presence || I18n.default_locale }.merge(extra)
  end
end

RSpec.configure do |c|
  c.include LocaleHelpers, type: :request
end
