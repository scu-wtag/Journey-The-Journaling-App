class ProfilesController < ApplicationController
  before_action :ensure_profile!, only: %i(show update)

  def show; end

  def update
    perform_profile_update!
    respond_update_success
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => error
    respond_update_failure(error)
  end

  private

  def perform_profile_update!
    Profile.transaction do
      update_profile_if_needed
      update_user_if_needed
    end
  end

  def respond_update_success
    respond_to do |format|
      format.html do
        redirect_to profile_path(locale: I18n.locale),
                    notice: t('profiles.update.success', default: 'Profile updated')
      end
    end
  end

  def respond_update_failure(error)
    respond_to do |format|
      format.html do
        flash.now[:alert] = t('profiles.update.failed', default: 'Update failed')
        render :show, status: :unprocessable_content
      end
      format.json do
        render json: { error: 'invalid', message: error.record.errors.full_messages },
               status: :unprocessable_content
      end
    end
  end

  def ensure_profile!
    @profile = current_user.profile || current_user.create_profile!
  end

  def update_profile_if_needed
    profile_params = params.fetch(:profile, {})
    return if profile_params.blank?

    apply_phone_params!(profile_params)
    @profile.assign_attributes(profile_params.permit(:picture, :headquarters, :phone_country_code,
                                                     :phone_local, :birthday))
    @profile.save!
  end

  def update_user_if_needed
    user_params = params.fetch(:user, {})
    return if user_params.blank?

    current_user.update!(user_params.permit(:locale, :theme, :email, :name))
    prefs_cookies_from_params(user_params)
  end

  def prefs_cookies_from_params(user_params)
    cookies.permanent[:locale] = current_user.locale if user_params.key?(:locale)
    cookies.permanent[:theme] = current_user.theme if user_params.key?(:theme)
  end

  def apply_phone_params!(user_params)
    return unless needs_phone_update?(user_params)

    code, local = sanitized_phone_parts(user_params)
    set_profile_phone(@profile, code, local)
  end

  def needs_phone_update?(user_params)
    user_params.key?(:phone_country_code) || user_params.key?(:phone_local)
  end

  def sanitized_phone_parts(user_params)
    code = user_params[:phone_country_code].to_s.strip.gsub(/\D/, '')
    local = user_params[:phone_local].to_s.gsub(/\D/, '')
    [code, local]
  end

  def set_profile_phone(profile, code, local)
    profile.phone_country_code = code
    profile.phone_local = local
    profile.phone = code.present? && local.present? ? "+#{code}#{local}" : nil
  end
end
