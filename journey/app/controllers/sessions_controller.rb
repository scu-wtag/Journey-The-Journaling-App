class SessionsController < Clearance::SessionsController
  def new
    @session = SessionForm.new(email: params.dig(:session, :email))
  end

  def create
    @session = SessionForm.new(session_params)

    if (user = @session.authenticate)
      sign_in user
      redirect_to root_path, notice: t('sessions.success')
    else
      flash.now[:alert] = t('sessions.errors.wrong_email_or_password')
      render :new, status: :unprocessable_content
    end
  end

  private

  def url_after_create
    session[:team_ids] = current_user.teams.pluck(:id) if signed_in? && current_user.respond_to?(:teams)
    root_path
  end

  def url_after_destroy
    login_path
  end

  def session_params
    params.expect(session: %i(email password))
  end
end
