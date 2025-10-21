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
        redirect_to profile_path(locale: I18n.locale), notice: t('.success', default: 'Profile updated')
      end
      format.json { head :no_content }
    end
  end

  def respond_update_failure(error)
    respond_to do |format|
      format.html do
        flash.now[:alert] = t('.failed', default: 'Update failed')
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
    raw = params.fetch(:profile, {})
    return if raw.blank?

    apply_phone_params!(raw)
    @profile.assign_attributes(raw.permit(:picture, :headquarters, :phone_country_code, :phone_local,
                                          :birthday))
    @profile.save!
  end

  def update_user_if_needed
    raw = params.fetch(:user, {})
    return if raw.blank?

    current_user.update!(raw.permit(:locale, :theme, :email, :name))
    prefs_cookies_from_params(raw)
  end

  def prefs_cookies_from_params(raw)
    cookies.permanent[:locale] = current_user.locale if raw.key?(:locale)
    cookies.permanent[:theme] = current_user.theme if raw.key?(:theme)
  end

  def apply_phone_params!(raw)
    return unless needs_phone_update?(raw)

    code, local = sanitized_phone_parts(raw)
    set_profile_phone(@profile, code, local)
  end

  def needs_phone_update?(raw)
    raw.key?(:phone_country_code) || raw.key?(:phone_local)
  end

  def sanitized_phone_parts(raw)
    code = raw[:phone_country_code].to_s.strip.gsub(/\D/, '')
    local = raw[:phone_local].to_s.gsub(/\D/, '')
    [code, local]
  end

  def set_profile_phone(profile, code, local)
    profile.phone_country_code = code
    profile.phone_local = local
    profile.phone = code.present? && local.present? ? "+#{code}#{local}" : nil
  end
end
