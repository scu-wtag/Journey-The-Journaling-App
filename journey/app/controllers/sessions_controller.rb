class SessionsController < Clearance::SessionsController
  def create
    creds = params.expect(session: %i(email password))
    @email = creds[:email]

    user = User.find_by(email: creds[:email])

    if user&.authenticated?(creds[:password])
      sign_in user
      redirect_to root_path(locale: I18n.locale), notice: t('.success')
    else
      flash.now[:alert] = t('.invalid')
      render :new, status: :unauthorized
    end
  end

  private

  def url_after_create
    root_path(locale: I18n.locale || I18n.default_locale)
  end
end
