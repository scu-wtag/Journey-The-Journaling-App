class SessionsController < Clearance::SessionsController
  def create
    @user = authenticate(params)

    if @user
      sign_in @user
      redirect_to url_after_create, notice: t("sessions.success", default: t("sessions.success", default: ""))
    else
      flash.now[:alert] = t("users.create.failed", default: t("sessions.new.alert"))
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

  def session_params
    params.expect(session: %i(email password))
  end
end