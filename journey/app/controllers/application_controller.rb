# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Clearance::Controller

  before_action :set_locale

  # Diese DSL ist optional (kommt aus einem Gem). Nur anwenden, wenn vorhanden.
  allow_browser versions: :modern if respond_to?(:allow_browser)

  private

  def set_locale
    I18n.locale =
      if params[:locale].present? && I18n.available_locales.map(&:to_s).include?(params[:locale])
        params[:locale]
      else
        I18n.default_locale
      end
  end

  def default_url_options
    { locale: I18n.locale }.merge(super)
  end
end
