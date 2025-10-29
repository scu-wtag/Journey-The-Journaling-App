require rails_helper

RSpec.describe TeamsController do
  let(:password) { 'SuperSecret123!' }
  let!(:user) { create(:user, email: 'test@example.com', password: password) }
  let!(:team) { create(:team) }
  let!(:membership) { create(:membership, user: user, team: team, role: :admin) }
end
