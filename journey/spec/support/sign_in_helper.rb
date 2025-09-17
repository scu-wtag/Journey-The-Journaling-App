module SignInHelpers
  def sign_in!(user, password: 'secret123', locale: I18n.locale)
    post login_path(locale: locale), params: { session: { email: user.email, password: password } }
    follow_redirect! if respond_to?(:follow_redirect!)
    user
  end
end
