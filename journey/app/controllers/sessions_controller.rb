class SessionsController < Clearance::SessionsController
  def new
    @session = Clearance::Session.new(session)
  end

  def create
    @user = authenticate(params)

    if @user
      sign_in @user
      redirect_to url_after_create, notice: t('sessions.success', default: t('sessions.success', default: ''))
    else
      flash.now[:alert] = t('sessions.errors.invalid_credentials', default: t('sessions.new.alert'))
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    sign_out
    redirect_to url_after_destroy, notice: t("sessions.sign_out")
  end

  private

  def url_after_create
    session[:team_ids] = current_user.teams.pluck(:id) if signed_in? && current_user.respond_to?(:teams)
    root_path
  end

  def url_after_destroy
    login_path
  end
end