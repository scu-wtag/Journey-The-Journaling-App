class UsersController < Clearance::UsersController
  prepend_before_action :require_signed_out, only: %i[new create]
  before_action :build_user,         only: :new
  before_action :prepare_user,       only: :create

  def new; end

  def create
    check_password_confirmation
    normalize_phone!(@user.profile)

    if @user.email.present? && User.exists?(email: @user.email.to_s.downcase)
      @user.errors.add(:email, :taken)
    end

    return render_new_error if @user.errors.any?
    return handle_success if @user.save

    if @user.save
      handle_success
    else
      handle_failure
    end
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
    p = user_params
    attrs = {
      email:    p[:email],
      password: p[:password],
      name:     p[:name]
    }

    if p[:profile_attributes].present?
      attrs[:profile_attributes] = sanitize_profile_attrs(p[:profile_attributes])
    end

    User.new(attrs)
  end

  def sanitize_profile_attrs(raw)
    allowed = Profile.attribute_names.map(&:to_sym)
    raw.to_h.symbolize_keys.slice(*allowed)
  end

  def user_params
    params.fetch(:user, {}).permit(
      :email, :password, :password_confirmation, :name,
      profile_attributes: %i(phone_country_code phone_local phone birthday country headquarters)
    )
  end

  def check_password_confirmation
    return unless password_confirmation_mismatch?
    add_password_mismatch_error
  end

  def password_confirmation_mismatch?
    password  = params.dig(:user, :password)
    confirmation = params.dig(:user, :password_confirmation)
    @user.errors.add(:password, :mismatch) if confirmation.present? && password != confirmation
  end

  def normalize_phone!(profile)
    return unless profile

    code = profile.phone_country_code.to_s.strip
    local = profile.phone_local.to_s.gsub(/\D/, '')
    profile.phone = code.present? && local.present? ? "+#{code}#{local}" : nil
  end

  def render_new_error
    flash.now[:alert] = t("users.create.failed", default: "")
    render :new, status: :unprocessable_content
  end

  def handle_success
    redirect_to(
      Clearance.configuration.redirect_url,
      notice: t("users.create.success"),
    )
  end

  def handle_failure
    flash.now[:alert] = t("users.create.failed", default: "")
    render :new, status: :unprocessable_content
  end
end
