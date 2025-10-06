class ApplicationController < ActionController::Base
  include Clearance::Controller

  before_action :set_locale
  before_action :require_login
  before_action :set_theme

  ALLOWED_THEMES = %w(light dark).freeze

  LIGHT_THEME = 'light'.freeze
  DARK_THEME = 'dark'.freeze
  ALLOWED_THEMES = [LIGHT_THEME, DARK_THEME].freeze

  private

  def url_after_denied_access_when_signed_out
    login_url(locale: params[:locale] || I18n.locale)
  end

  def set_locale
    available = I18n.available_locales.map(&:to_s)
    chosen = chosen_locale(available).to_s
    I18n.locale = available.include?(chosen) ? chosen : I18n.default_locale
    session[:locale] = I18n.locale
  end

  def chosen_locale(avail)
    raw = params[:locale].to_s
    return raw if raw.present?

    if respond_to?(:signed_in?) && signed_in?
      user_locale(avail) ||
        cookies[:locale].to_s.presence_in(avail) ||
        session[:locale].to_s.presence_in(avail) ||
        browser_locale_from_header(avail) ||
        I18n.default_locale
    else
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
    languages = accept_language_values
    direct = languages.detect { |l| l.to_s.presence_in(avail) }
    direct || languages.map { |l| l[0, 2] }.detect { |code| code.to_s.presence_in(avail) }
  end

  def accept_language_values
    header = request&.env&.fetch('HTTP_ACCEPT_LANGUAGE', '').to_s
    languages = header.split(',').map { |l| l.split(';').first.to_s }
    languages.detect { |l| l.presence_in(avail) } ||
      languages.map { |l| l[0, 2] }.detect { |code| code.presence_in(avail) }
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
