class UsersController < Clearance::UsersController
  before_action :redirect_signed_in, only: %i(new create)
  before_action :build_user,         only: :new
  before_action :prepare_user,       only: :create

  def new; end

  def create
    check_password_confirmation
    normalize_phone!(@user.profile)

    return render_new_error   if @user.errors.any?
    return handle_success     if @user.save

    handle_failure
  end

  private

  def build_user
    @user = User.new
    @user.build_profile unless @user.profile
  end

  def prepare_user
    @user = user_from_params
  end

  def check_password_confirmation
    return unless password_confirmation_mismatch?
    add_password_mismatch_error
  end

  def password_confirmation_mismatch?
    pwd  = params.dig(:user, :password)
    conf = params.dig(:user, :password_confirmation)
    conf.present? && pwd != conf
  end

  def add_password_mismatch_error
    @user.errors.add(:password, :mismatch)
  end

  def normalize_phone!(profile)
    return unless profile
    code  = profile.phone_country_code.to_s.strip
    local = profile.phone_local.to_s.gsub(/\D/, '')
    profile.phone = "+#{code}#{local}" if code.present? && local.present?
  end

  def handle_success
    redirect_to Clearance.configuration.redirect_url,
                notice: t('users.create.success')
  end

  def handle_failure
    flash.now[:alert] = t('users.create.failed', default: '')
    render_new_invalid
  end

  def render_new_error
    render :new, status: :unprocessable_content
  end

  def render_new_invalid
    render :new, status: :unprocessable_content
  end

  def user_from_params
    p = user_params
    User.new(
      email:  p[:email],
      password: p[:password],
      name:   p[:name],
      profile_attributes: p[:profile_attributes],
    )
  end

  def user_params
    params.fetch(:user, {}).permit(
      :email, :password, :password_confirmation, :name,
      profile_attributes: %i(phone_country_code phone_local phone bday country hq)
    )
  end


  def redirect_signed_in
    redirect_to root_path if signed_in?
  end
end
