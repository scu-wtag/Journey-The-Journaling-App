module Settings
  class PasswordsController < ApplicationController
    def update
      if Current.user.update(password_params)
        redirect_to settings_profile_path, status: :see_other, notice: t('users.password.update')
      else
        render :show, status: :unprocessable_content
      end
    end

    private

    def password_params
      params.expect(user: %i(password password_confirmation
                             password_challenge)).with_defaults(password_challenge: '')
    end
  end
end
