class TeamInvitationsController < ApplicationController
  before_action :set_team

  def new
    redirect_to @team,
                alert: t('teams.invite.not_ready',
                         default: 'Email invites coming soon. Please use "Add member by email" for now.')
  end

  def create
    redirect_to @team,
                alert: t('teams.invite.not_ready',
                         default: 'Email invites coming soon. Please use "Add member by email" for now.')
  end

  private

  def set_team
    @team = Team.find(params[:team_id])
    authorize! :read, @team
  end
end
