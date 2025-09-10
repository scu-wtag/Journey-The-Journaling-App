class ApplicationController < ActionController::Base
  before_action :set_locale
  include Clearance::Controller
  allow_browser versions: :modern
  private

  def set_locale
    I18n.locale = if params[:locale].present? && I18n.available_locales.map(&:to_s).include?(params[:locale])
      params[:locale]
    else
      I18n.default_locale
    end
  end

  def default_url_options
    { locale: I18n.locale }.merge(super)
  end
end
