module RequestSpecAuthHelpers
  def sign_in_as(user, password: 'password123')
    post sign_in_path, params: { session: { email: user.email, password: password } }
    follow_redirect! if response.redirect?
    user
  end

  def sign_out
    delete sign_out_path
    follow_redirect! if response.redirect?
  end
end
RSpec.configure { |c| c.include RequestSpecAuthHelpers, type: :request }
