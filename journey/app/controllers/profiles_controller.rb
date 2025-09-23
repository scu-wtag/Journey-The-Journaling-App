class ProfilesController < ApplicationController
  before_action :require_login

  def show
    @user = current_user
    @profile = current_user.profile || current_user.build_profile
  end

  def edit
    @profile = current_user.profile || current_user.build_profile
  end

  def update
    @profile = current_user.profile || current_user.build_profile
    if @profile.update(profile_params)
      redirect_to profile_path, notice: 'Profile updated'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.expect(profile: %i(phone_country_code phone_local birthday country headquarters
                              picture))
  end
end
