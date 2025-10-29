# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TeamMembers', type: :request do
  let(:user) { create(:user) }
  let(:team) { create(:team) }
  let!(:admin_membership) { create(:membership, team: team, user: user, role: :admin) }
  let(:target_user) { create(:user) }
  let!(:member_membership) { create(:membership, team: team, user: target_user, role: :member) }
  let(:loc) { :en }

  def sign_in(u)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(u)
    allow_any_instance_of(ApplicationController).to receive(:signed_in?).and_return(true)
  end

  before do
    sign_in(user)
    allow_any_instance_of(TeamMembersController).to receive(:authorize!).and_return(true)
  end

  describe 'POST /teams/:team_id/members' do
    it 'adds a user by email' do
      post team_team_members_path(team, locale: loc), params: { email: target_user.email, role: 'admin' }
      expect(response).to redirect_to(team_path(team, locale: loc))
      expect(team.memberships.find_by(user_id: target_user.id).role).to eq('admin')
    end

    it 'defaults to member if role is invalid' do
      post team_team_members_path(team, locale: loc), params: { email: target_user.email, role: 'invalid' }
      expect(team.memberships.find_by(user_id: target_user.id).role).to eq('member')
    end
  end

  describe 'PATCH /teams/:team_id/members/:id' do
    it 'updates role' do
      patch team_team_member_path(team, member_membership, locale: loc), params: { role: 'admin' }
      expect(response).to redirect_to(team_path(team, locale: loc))
      expect(member_membership.reload.role).to eq('admin')
    end
  end

  describe 'DELETE /teams/:team_id/members/:id' do
    it 'removes a member' do
      delete team_team_member_path(team, member_membership, locale: loc)
      expect(response).to redirect_to(team_path(team, locale: loc))
      expect { member_membership.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'admin guard' do
    it 'blocks non-admin users' do
      admin_membership.update!(role: :member)
      delete team_team_member_path(team, member_membership, locale: loc)
      expect(response).to redirect_to(team_path(team, locale: loc))
      follow_redirect!
      expect(response.body).to include('not authorized')
    end
  end
end
