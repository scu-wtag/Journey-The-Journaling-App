class TeamMembersController < ApplicationController
  before_action :set_team
  before_action :require_admin!
  before_action :set_membership, only: %i(update destroy)
  before_action :guard_last_admin_on_update!, only: :update
  before_action :guard_last_admin_on_destroy!, only: :destroy

  def create
    email = params[:email].to_s.strip.downcase
    role = Membership.roles.key?(params[:role].to_s) ? params[:role].to_s : 'member'

    user = User.find_by('LOWER(email) = ?', email)
    return redirect_to(@team, alert: t('teams.members.user_not_found', default: 'User not found')) unless user

    membership = @team.memberships.find_or_initialize_by(user_id: user.id)
    membership.role = role

    if membership.persisted?
      redirect_to @team, notice: t('teams.members.already_exists', default: 'User is already a team member')
    elsif membership.save
      redirect_to @team, notice: t('teams.members.added', default: 'Member added')
    else
      redirect_to @team, alert: membership.errors.full_messages.to_sentence
    end
  end

  def update
    role = params[:role].to_s
    unless Membership.roles.key?(role)
      return redirect_to(@team,
                         alert: t('teams.members.invalid_role',
                                  default: 'Invalid role'))
    end

    if @membership.update(role: role)
      redirect_to @team, notice: t('teams.members.role_updated', default: 'Role updated')
    else
      redirect_to @team, alert: @membership.errors.full_messages.to_sentence
    end
  end

  def destroy
    @membership.destroy
    redirect_to @team, notice: t('teams.members.removed', default: 'Member removed')
  end

  private

  def set_team
    @team = Team.find(params[:team_id])
    authorize! :read, @team
  end

  def set_membership
    @membership = @team.memberships.find(params[:id])
    authorize! :manage, @membership
  end

  def require_admin!
    allowed = Membership.exists?(team_id: @team.id, user_id: current_user.id, role: :admin)
    redirect_to @team, alert: t('teams.members.not_authorized', default: 'Not authorized') unless allowed
  end

  def last_admin?
    @team.memberships.role_admin.one?
  end

  def guard_last_admin_on_update!
    demoting_admin = @membership.role_admin? && params[:role].to_s != 'admin'
    return unless demoting_admin && last_admin?

    redirect_to(@team,
                alert: t('teams.members.last_admin_guard',
                         default: 'Cannot demote the last admin'))
  end

  def guard_last_admin_on_destroy!
    removing_last_admin = @membership.role_admin? && last_admin?
    return unless removing_last_admin

    redirect_to(@team,
                alert: t('teams.members.last_admin_guard',
                         default: 'Cannot remove the last admin'))
  end
end
