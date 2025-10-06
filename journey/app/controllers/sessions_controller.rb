class SessionsController < ApplicationController
  skip_before_action :require_login, only: %i(new create)

  def new
    @session = Clearance::Session.new(session)
  end

  def create
    email = params.dig(:session, :email).to_s.downcase.strip
    password = params.dig(:session, :password)
    @user = User.find_by(email: email)

    if @user&.authenticated?(password)
      perform_sign_in(@user)
      redirect_to url_after_create, notice: t('sessions.success', default: '')
    else
      failed_sign_in
    end
  end

  def destroy
    sign_out
    reset_session
    redirect_to login_path, notice: t('sessions.sign_out')
  end

  private

  def credentials_from_params
    [
      params.dig(:session, :email).to_s.downcase.strip,
      params.dig(:session, :password).to_s,
    ]
  end

  def perform_sign_in(user)
    cookies[Clearance.configuration.cookie_name] = { value: user.remember_token, httponly: true }
    session[:team_ids] = user.respond_to?(:teams) ? user.teams.pluck(:id) : []
  end

  def failed_sign_in
    flash.now[:alert] = t('sessions.errors.invalid_credentials', default: '')
    render :new, status: :unprocessable_content
  end

  def url_after_create
    root_path
  end

  def url_after_destroy
    login_path
  end
end
