class UsersController < Clearance::UsersController
  prepend_before_action :require_signed_out, only: %i(new create)

  before_action :build_user, only: :new
  before_action :prepare_user, only: :create

  before_action :check_password_confirmation, only: :create

  def new; end

  def create
    return render_new_error if @user.errors.any?
    return handle_success if @user.save

    handle_failure
  end

  private

  def require_signed_out
    return unless signed_in?

    redirect_to root_path(locale: params[:locale] || I18n.locale || I18n.default_locale)
  end

  def build_user
    @user = User.new
    @user.build_profile unless @user.profile
  end

  def prepare_user
    @user = user_from_params
    @user.build_profile unless @user.profile
  end

  def user_from_params
    params_ = user_params
    attrs = {
      email: params_[:email],
      password: params_[:password],
      name: params_[:name],
    }

    if params_[:profile_attributes].present?
      attrs[:profile_attributes] = sanitize_profile_attrs(params_[:profile_attributes])
    end

    User.new(attrs)
  end

  def user_params
    params.fetch(:user, {}).permit(
      :email, :password, :password_confirmation, :name,
      profile_attributes: %i(phone_country_code phone_local phone birthday country headquarters)
    )
  end

  def sanitize_profile_attrs(raw)
    virtual = %i(phone_country_code phone_local picture)
    allowed = (Profile.attribute_names.map(&:to_sym) + virtual).uniq
    raw.to_h.symbolize_keys.slice(*allowed)
  end

  def check_password_confirmation
    password = params.dig(:user, :password)
    confirmation = params.dig(:user, :password_confirmation)
    return if confirmation.blank? || password == confirmation

    @user.errors.add(:password, :mismatch)
  end

  def render_new_error
    flash.now[:alert] = t('users.create.failed', default: '')
    render :new, status: :unprocessable_content
  end

  def handle_success
    sign_in(@user)
    redirect_to(Clearance.configuration.redirect_url, notice: t('users.create.success'))
  end

  def handle_failure
    flash.now[:alert] = t('users.create.failed', default: '')
    render :new, status: :unprocessable_content
  end
end
