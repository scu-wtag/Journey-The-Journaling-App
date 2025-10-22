require 'set'

class ApplicationController < ActionController::Base
  include Clearance::Controller

  before_action :set_locale
  before_action :require_login
  before_action :set_theme

  LIGHT_THEME = 'light'.freeze
  DARK_THEME = 'dark'.freeze
  ALLOWED_THEMES = [LIGHT_THEME, DARK_THEME].freeze

  def default_url_options
    { locale: I18n.locale }
  end

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
    return raw unless raw.empty?

    pick_locale(avail) || I18n.default_locale
  end

  def pick_locale(avail)
    allowed = Set.new(Array(avail).map(&:to_s))

    each_locale_source(avail) do |loc|
      s = loc.to_s
      return s if !s.empty? && allowed.include?(s)
    end

    nil
  end

  def each_locale_source(avail)
    yield user_locale(avail) if signed_in_safe?
    yield cookies[:locale]
    yield session[:locale]
    yield browser_locale_from_header(avail)
  end

  def signed_in_safe?
    signed_in?
  end

  def user_locale(avail)
    current_user&.locale.to_s.presence_in(avail)
  end

  def browser_locale_from_header(avail)
    languages = accept_language_values
    return nil if languages.blank?

    direct = languages.detect { |l| avail.include?(l) }
    direct || languages.map { |l| l[0, 2] }.detect { |code| avail.include?(code) }
  end

  def accept_language_values
    header = request&.env&.fetch('HTTP_ACCEPT_LANGUAGE', '').to_s
    header.split(',').
      map { |l| l.split(';').first.to_s.strip }.
      compact_blank
  end

  def set_theme
    @theme = first_allowed_theme(
      [
        cookies[:theme],
        (current_user.theme if signed_in_safe? && current_user),
      ],
      ALLOWED_THEMES,
    ) || LIGHT_THEME
  end

  def first_allowed_theme(candidates, allowed_list)
    allowed = Array(allowed_list).to_set(&:to_s)
    candidates.
      compact.
      lazy.
      map(&:to_s).
      detect { |t| t.present? && allowed.include?(t) }
  end
end
