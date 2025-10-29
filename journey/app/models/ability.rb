class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new(role: :guest)
    return can(:manage, :all) if user.admin?
    return unless user.member?

    can :create, Team
    can :read, Team, memberships: { user_id: user.id }
    can(:update, Team) { |team| admin_of_team?(user, team.id) }
    can(:destroy, Team) { |team| admin_of_team?(user, team.id) }

    can(:manage, Membership) { |m| admin_of_team?(user, m.team_id) }

    return unless defined?(Task)

    team_ids = user.team_ids
    can :read, Task, team_id: team_ids
    can :create, Task, team_id: team_ids
    can(:update, Task) { |t| t.creator_id == user.id || admin_of_team?(user, t.team_id) }
    can(:destroy, Task) { |t| t.creator_id == user.id || admin_of_team?(user, t.team_id) }
  end

  private

  def admin_of_team?(user, team_id)
    Membership.exists?(user_id: user.id, team_id: team_id, role: :admin)
  end
end
