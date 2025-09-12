class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new(role: :guest)

    if user.role?(:admin)
      can :manage, :all
    elsif user.role?(:member)
      can :read, :all
    end
  end
end
