class SessionsController < Clearance::SessionsController
  def new
    super
  end

  def create
    super
  ensure
    flash.now[:email] = params.dig(:session, :email)
    flash.now[:password] = params.dig(:session, :password)
  end
end
