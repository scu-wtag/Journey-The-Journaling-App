module LoginHelpers
  def sign_in_as(user)
    cookies[Clearance.configuration.cookie_name] = user.remember_token
  end
end

RSpec.configure do |c|
  c.include LoginHelpers, type: :request
end
