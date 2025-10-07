class ApplicationController < ActionController::Base
  include Clearance::Controller

  LIGHT_THEME = 'light'.freeze
  DARK_THEME = 'dark'.freeze
  ALLOWED_THEMES = [LIGHT_THEME, DARK_THEME].freeze

  before_action :set_locale
  before_action :set_theme

  private

  def url_after_denied_access_when_signed_out
    login_url(locale: params[:locale] || I18n.locale)
  end

  def set_locale
    available = I18n.available_locales.map(&:to_s)
    I18n.locale = chosen_locale(available)
    session[:locale] = I18n.locale
  end

  def chosen_locale(avail)
    param_locale = params[:locale].to_s.presence_in(avail)

    if respond_to?(:signed_in?) && signed_in?
      user_locale(avail) || I18n.default_locale
    else
      param_locale ||
        cookies[:locale].to_s.presence_in(avail) ||
        session[:locale].to_s.presence_in(avail) ||
        browser_locale_from_header(avail) ||
        I18n.default_locale
    end
  end

  def user_locale(avail)
    current_user&.locale.to_s.presence_in(avail)
  end

  def browser_locale_from_header(avail)
    header = request&.env&.fetch('HTTP_ACCEPT_LANGUAGE', '').to_s
    languages = header.split(',').map { |l| l.split(';').first.to_s }
    languages.detect { |l| l.to_s.presence_in(avail) } ||
      languages.map { |l| l[0, 2] }.detect { |code| code.to_s.presence_in(avail) }
  end

  def set_theme
    cookie_theme = cookies[:theme].to_s
    cookie_theme = cookie_theme if ALLOWED_THEMES.include?(cookie_theme)

    user_theme =
      if respond_to?(:signed_in?) && signed_in? && current_user
        t = current_user.theme.to_s
        ALLOWED_THEMES.include?(t) ? t : nil
      end

    @theme = cookie_theme.presence || user_theme.presence || LIGHT_THEME
  end
end
