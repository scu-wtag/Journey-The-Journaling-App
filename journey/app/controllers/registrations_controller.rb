class RegistrationsController < Clearance::UsersController
  before_action :build_user, only: :new
  before_action :prepare_user, only: :create

  def new
    render 'users/new'
  end

  def create
    check_password_confirmation
    normalize_phone!(@user.profile)

    return render_new_error if @user.errors.any?
    return handle_success if @user.save

    handle_failure
  end

  private

  def build_user
    @user = User.new
    @user.build_profile unless @user.profile
  end

  def prepare_user
    @user = user_from_params
    @user.build_profile unless @user.profile
  end

  def user_from_params
    User.new(user_params)
  end

  def user_params
    params.fetch(:user, {}).permit(
      :email, :password, :password_confirmation, :name,
      profile_attributes: %i(phone_country_code phone_local phone birthday country headquarters)
    )
  end

  def check_password_confirmation
    password = params.dig(:user, :password)
    confirmation = params.dig(:user, :password_confirmation)
    return if confirmation.blank? || password == confirmation

    confirmation = params.dig(:user, :password_confirmation)
    return if confirmation.blank? || password == confirmation

    @user.errors.add(:password, :mismatch)
  end

  def normalize_phone!(profile)
    return unless profile

    code = (profile.phone_country_code.presence || params.dig(:user, :profile_attributes,
                                                              :phone_country_code)).to_s.strip
    local = (profile.phone_local.presence || params.dig(:user, :profile_attributes, :phone_local)).to_s.gsub(
      /\D/, ''
    )
    profile.phone = code.present? && local.present? ? "+#{code}#{local}" : nil
  end

  def render_new_error
    render 'users/new', status: :unprocessable_content
  end

  def handle_success
    redirect_to Clearance.configuration.redirect_url, notice: t('users.create.success')
    sign_in @user
  end

  def handle_failure
    flash.now[:alert] = t('users.create.failed', default: '')
    render 'users/new', status: :unprocessable_content
  end

  prepend_before_action :require_signed_out, only: %i(new create)
  def require_signed_out
    return unless signed_in?

    redirect_to root_path(locale: params[:locale] || I18n.locale || I18n.default_locale)
  end
end
