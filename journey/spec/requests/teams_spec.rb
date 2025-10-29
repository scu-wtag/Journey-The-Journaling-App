require 'rails_helper'

RSpec.describe 'Teams', type: :request do
  let(:user) { create(:user) }
  let!(:team) { create(:team, name: 'Test Team') }
  let!(:membership) { create(:membership, team: team, user: user, role: :admin) }

  def sign_in(user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow_any_instance_of(ApplicationController).to receive(:signed_in?).and_return(true)
  end

  before do
    sign_in(user)
    allow_any_instance_of(TeamsController).to receive(:authorize!).and_return(true)
  end

  describe 'GET /teams' do
    it 'returns 200 and lists user teams' do
      get teams_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Test Team')
    end
  end

  describe 'GET /teams/:id' do
    it 'shows the team' do
      get teams_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Test Team')
    end
  end

  describe 'GET /teams/new' do
    it 'renders the new form' do
      get new_team_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /teams' do
    context 'with valid parameters' do
      it 'creates a team and redirects' do
        params = { team: { name: 'Second Team' } }
        expect do
          post teams_path, params: params
        end.to change(Team, :count).by(1).and change(Membership, :count).by(1)

        created_team = Team.order(:created_at).last
        admin_membership = created_team.memberships.find_by(role: :admin)

        expect(admin_membership.role).to eq('admin')
        expect(response).to redirect_to(team_path(created_team))
      end
    end

    context 'with invalid parameters' do
      it 'renders new with 422' do
        post teams_path, params: { team: { name: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to match(/Name/i).or include("can't be blank")
      end
    end
  end
end
