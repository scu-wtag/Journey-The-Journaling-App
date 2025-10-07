class ProfilesController < ApplicationController
  before_action :require_login
  before_action :ensure_profile!, only: %i(show edit update)

  def show; end
  def edit; end

  def update
    ActiveRecord::Base.transaction do
      update_user_if_needed
      update_profile_if_needed
    end

    respond_to do |format|
      format.html do
        redirect_to profile_path(locale: I18n.locale),
                    notice: t('.success')
      end
      format.json { head :no_content }
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.html do
        flash.now[:alert] = t('.failed')
        render :show, status: :unprocessable_entity
      end
      format.json { render json: { error: 'invalid' }, status: :unprocessable_entity }
    end
  end

  private

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

  def update_profile_if_needed
    profileparams = params[:profile]
    return if profileparams.blank?

    apply_phone_params!(@profile, profileparams)
    @profile.assign_attributes(profile_params)
    @profile.save! if @profile.changed? || profileparams.key?(:picture)
  end

  def apply_phone_params!(profile, profileparams)
    return unless profileparams.key?(:phone_country_code) || profileparams.key?(:phone_local)

    code = profileparams[:phone_country_code].to_s.strip
    local = profileparams[:phone_local].to_s.gsub(/\D/, '')

    profile.phone_country_code = code
    profile.phone_local = local
    profile.phone = code.present? && local.present? ? "+#{code}#{local}" : nil
  end

  def ensure_profile!
    @profile = current_user.profile || current_user.create_profile!
  end

  def profile_params
    params.fetch(:profile, {}).permit(:birthday, :country, :headquarters, :picture)
  end

  def user_params
    params.expect(user: %i(email name theme locale))
  end
end
