module RequestHelpers
  def loc(extra = {})
    { locale: I18n.locale }.merge(extra)
  end

  def upload(path, mime)
    Rack::Test::UploadedFile.new(Rails.root.join(path), mime)
  end

  def sign_in_as(user, password: 'password123')
    user.update!(password: password)
    post session_path, params: { session: { email: user.email, password: password } }
    follow_redirect! if response.redirect?
  end
end

RSpec.configure do |c|
  c.include RequestHelpers, type: :request
end
