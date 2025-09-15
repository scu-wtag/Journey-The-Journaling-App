require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability do
  subject(:ability) { described_class.new(user) }

  context 'as admin' do
    let(:user) { build(:user, :admin) }

    it 'can manage all' do
      expect(ability).to be_able_to(:manage, :all)
    end
  end

  context 'as member' do
    let(:user) { build(:user, :member) }

    it 'can read all, but cannot manage all' do
      expect(ability).to be_able_to(:read, :all)
      expect(ability).not_to be_able_to(:manage, :all)
    end
  end

  context 'as guest (nil user becomes guest)' do
    let(:user) { nil }

    it 'has no abilities by default' do
      # No explicit permissions set for guests in Ability
      expect(ability.can?(:read, :anything)).to be(false)
      expect(ability.can?(:manage, :all)).to be(false)
    end
  end
end
