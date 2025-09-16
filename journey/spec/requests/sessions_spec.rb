# spec/requests/sessions_spec.rb
require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:password) { "secret123" }
  let(:user)     { create(:user, password:) }

  describe "POST /login (sign in)" do
    it "logs the user in with valid credentials and redirects" do
      post login_path, params: { session: { email: user.email, password: password } }
      expect(response).to redirect_to(root_path(locale: I18n.locale))
      follow_redirect!
      expect(response).to have_http_status(:ok)

      cookie_name = Clearance.configuration.cookie_name
      expect(cookies[cookie_name]).to be_present
    end

    it "does not log in with invalid password" do
      post login_path, params: { session: { email: user.email, password: "wrong" } }
      expect(response).to have_http_status(:ok)
        .or have_http_status(:unprocessable_content)
        .or have_http_status(:unauthorized)
    end
  end

  context "team placement remains the same" do
    let!(:team) { create(:team) }
    let!(:membership) { create(:membership, user:, team:, role: :member) }

    it "keeps the user in the same teams after login" do
      post login_path, params: { session: { email: user.email, password: password } }
      follow_redirect!
      expect(user.reload.teams).to include(team)
    end
  end
end
