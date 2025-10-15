class UsersController < Clearance::UsersController
  prepend_before_action :require_signed_out, only: %i[new create]
  before_action :build_user, only: :new
  before_action :prepare_user, only: :create

  def new; end

  def create
    normalize_phone!(@user.profile)

    return render_new_error if @user.errors.any?
    return handle_success if @user.save

    handle_failure
  end

  private

  def require_signed_out
    return unless signed_in?
    redirect_to root_path
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
    params = user_params
    attrs = {
      email: params[:email],
      password: params[:password],
      password_confirmation: params[:password_confirmation],
      name: params[:name],
    }

    if params[:profile_attributes].present?
      attrs[:profile_attributes] = sanitize_profile_attrs(params[:profile_attributes])
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

  def normalize_phone!(profile)
    return unless profile
    code = profile.phone_country_code.to_s.strip
    local = profile.phone_local.to_s.gsub(/\D/, '')
    profile.phone = code.present? && local.present? ? "+#{code}#{local}" : nil
  end

  def render_new_error
    flash.now[:alert] = t('users.create.failed', default: '')
    render :new, status: :unprocessable_content
  end

  def handle_success
    redirect_to(
      Clearance.configuration.redirect_url,
      notice: t('users.create.success'),
    )
  end

  def handle_failure
    flash.now[:alert] = t('users.create.failed', default: '')
    render :new, status: :unprocessable_content
  end
end
