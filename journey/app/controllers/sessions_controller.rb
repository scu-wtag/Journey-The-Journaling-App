class SessionsController < Clearance::SessionsController
  def create
    super
  ensure
    flash.now[:email] = params.dig(:session, :email)
    flash.now[:password] = params.dig(:session, :password)
  end

  private

  def url_after_create
    root_path(locale: I18n.locale || I18n.default_locale)
  end
end
