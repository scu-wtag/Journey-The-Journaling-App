require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:password) { 'SuperSecret123!' }
  let!(:user) { create(:user, email: 'test@example.com', password: password) }
  let!(:team) { create(:team) }
  let!(:membership) { create(:membership, user: user, team: team, role: :member) }

  describe 'POST /login (sign in)' do
    it 'logs the user in with valid credentials and redirects' do
      post :create, params: { session: { email: user.email, password: password } }

      expect(response).to redirect_to(root_path)

      cookie_name = Clearance.configuration.cookie_name
      expect(cookies[cookie_name]).to be_present
    end

    it 'does not log in with invalid password' do
      post :create, params: { session: { email: user.email, password: 'wrong' } }

      expect(response).to have_http_status(:ok).
        or have_http_status(:unprocessable_content).
        or have_http_status(:unauthorized)
    end
  end

  describe 'team placement remains the same' do
    it 'keeps the user in the same teams after login' do
      post :create, params: { session: { email: user.email, password: password } }

      expect(session[:team_ids]).to match_array(user.teams.pluck(:id))
      expect(response).to redirect_to(root_path)
    end
  end
end
