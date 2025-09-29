module SignInHelpers
  def sign_in(user)
    allow_any_instance_of(ApplicationController).to receive(:signed_in?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end
end
