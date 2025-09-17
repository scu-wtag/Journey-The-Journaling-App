class RegistrationsController < Clearance::UsersController
  before_action :build_user, only: :new
  before_action :prepare_user, only: :create

  def new; end

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
    return unless password_confirmation_mismatch?

    @user.errors.add(:password, :mismatch)
  end

  def password_confirmation_mismatch?
    pwd = params.dig(:user, :password)
    conf = params.dig(:user, :password_confirmation)
    conf.present? && pwd != conf
  end

  def normalize_phone!(profile)
    return unless profile

    code = profile.phone_country_code.to_s.strip
    local = profile.phone_local.to_s.gsub(/\D/, '')
    profile.phone = code.present? && local.present? ? "+#{code}#{local}" : nil
  end

  def render_new_error
    render :new, status: :unprocessable_content
  end

  def handle_success
    redirect_to Clearance.configuration.redirect_url, notice: t('users.create.success')
  end

  def handle_failure
    flash.now[:alert] = t('users.create.failed', default: '')
    render :new, status: :unprocessable_content
  end

  prepend_before_action :require_signed_out, only: %i(new create)

  def require_signed_out
    redirect_to root_path(locale: I18n.locale) if signed_in?
  end
end
