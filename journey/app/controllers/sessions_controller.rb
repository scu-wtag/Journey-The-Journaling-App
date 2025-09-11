class SessionsController < Clearance::SessionsController
  private

  def url_after_create
    if signed_in? && current_user.respond_to?(:teams)
      session[:team_ids] = current_user.teams.pluck(:id)
    end
    root_path
  end

  def url_after_destroy
    login_path
  end
end
