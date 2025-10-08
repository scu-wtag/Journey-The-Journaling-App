class SessionsController < ApplicationController

  def new
    @session = Clearance::Session.new(session)
  end

  def create
    email = params.dig(:session, :email).to_s.downcase.strip
    password = params.dig(:session, :password).to_s
    @user = User.find_by(email: email)
    if @user&.authenticated?(password)
      cookies[Clearance.configuration.cookie_name] = {
        value: @user.remember_token,
        httponly: true,
      }
      session[:team_ids] = @user.respond_to?(:teams) ? @user.teams.pluck(:id) : []
      redirect_to url_after_create, notice: t('sessions.success', default: '')
    else
      flash.now[:alert] = t('sessions.errors.invalid_credentials', default: '')
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    cookies.delete(Clearance.configuration.cookie_name)
    redirect_to url_after_destroy, notice: t('sessions.sign_out')
  end

  private

  def url_after_create
    root_path
  end

  def url_after_destroy
    login_path
  end
end
