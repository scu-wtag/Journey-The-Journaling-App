class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new(role: :guest)

    if user.admin?
      can :manage, :all
    elsif user.member?
      can :read, :all
    end
  end
end
