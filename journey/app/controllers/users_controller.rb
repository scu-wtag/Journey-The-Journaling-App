class UsersController < Clearance::UsersController
  before_action :redirect_signed_in, only: [:new, :create]

  def new
    @user = User.new
    @user.build_profile unless @user.profile
  end

  def create
    @user = user_from_params

    if params[:user][:password_confirmation].present? &&
       params[:user][:password] != params[:user][:password_confirmation]
      @user.errors.add(:password, "does not match confirmation")
      return render :new, status: :unprocessable_entity
    end

    def create

    @user = user_from_params

      if params[:user][:password_confirmation].present? &&
        params[:user][:password] != params[:user][:password_confirmation]
        @user.errors.add(:password, "does not match confirmation")
        return render :new, status: :unprocessable_entity
      end

      if (pr = @user.profile)
        code  = pr.phone_country_code.to_s.strip
        local = pr.phone_local.to_s.gsub(/\D/, "")  # nur Ziffern
        pr.phone = "+#{code}#{local}" if code.present? && local.present?
      end

      if @user.save
        redirect_to Clearance.configuration.redirect_url, notice: "Account created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    if @user.save
      redirect_to Clearance.configuration.redirect_url, notice: "Account created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_from_params
    attrs    = user_params.to_h
    email    = attrs.delete("email")
    password = attrs.delete("password")
    name     = attrs.delete("name")
    attrs.delete("password_confirmation") # not persisted

    Clearance.configuration.user_model.new(attrs).tap do |user|
      user.email    = email
      user.password = password
      user.name     = name
    end
  end

  def user_params
    params.fetch(:user, {}).permit(
      :email, :password, :password_confirmation, :name,
      profile_attributes: [:phone_country_code, :phone_local, :phone, :bday, :country, :hq]
    )
  end

  def redirect_signed_in
    redirect_to dashboard_path if signed_in?
  end
end