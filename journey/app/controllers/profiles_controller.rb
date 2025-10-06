class ProfilesController < ApplicationController
  before_action :ensure_profile!, only: %i(show update)

  def update
    Profile.transaction do
      update_profile_if_needed
      update_user_if_needed
    end
    respond_to do |format|
      format.html { redirect_to profile_path, notice: t('.success', default: 'Saved') }
      format.json { head :no_content }
    end
  rescue ActiveRecord::RecordInvalid => error
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
    profileparams = params[:profile]
    return if profileparams.blank?

    apply_phone_params!(profileparams)
    @profile.assign_attributes(profile_params)
    @profile.save!
  end

  def update_user_if_needed
    userparams = params[:user]
    return if userparams.blank?

    current_user.update!(user_params)
    set_prefs_cookies_from_params(userparams)
  end

  def set_prefs_cookies_from_params(userparams)
    cookies.permanent[:locale] = current_user.locale if userparams.key?(:locale)
    cookies.permanent[:theme] = current_user.theme if userparams.key?(:theme)
  end

  def apply_phone_params!(profileparams)
    return unless profileparams.key?(:phone_country_code) || profileparams.key?(:phone_local)

    code = profileparams[:phone_country_code].to_s.strip.gsub(/\D/, '')
    local = profileparams[:phone_local].to_s.gsub(/\D/, '')
    @profile.phone_country_code = code
    @profile.phone_local = local
    @profile.phone = code.present? && local.present? ? "+#{code}#{local}" : nil
  end

  def profile_params
    params.fetch(:profile, {}).permit(:picture, :headquarters, :phone_country_code, :phone_local, :birthday)
  end

  def user_params
    params.fetch(:user, {}).permit(:locale, :theme, :email, :name)
  end
end
