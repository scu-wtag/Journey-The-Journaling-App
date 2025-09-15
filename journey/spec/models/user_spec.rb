require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_one(:profile).dependent(:destroy) }
    it { is_expected.to have_many(:memberships).dependent(:destroy) }
    it { is_expected.to have_many(:teams).through(:memberships) }
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for(:profile).update_only(true) }

    it 'builds a profile via nested attributes' do
      user = described_class.new(
        email: 'x@y.com', name: 'X', password: 'secret123',
        profile_attributes: { phone_country_code: '41', phone_local: '79 111 22 33' }
      )
      expect(user).to be_valid
      expect(user.profile).to be_present
    end
  end

  describe 'enums' do
    it 'defines role enum with default :member' do
      expect(described_class.roles.keys).to match_array(%w(guest member admin))
      user = build(:user)
      expect(user.role).to eq('member')
    end
  end

  describe 'validations' do
    subject { create(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'database indexes' do
    it { is_expected.to have_db_index(:email).unique }
  end

  describe 'callbacks' do
    it 'downcases email before save' do
      user = build(:user, email: 'MiXeD@Example.COM')
      user.save!
      expect(user.reload.email).to eq('mixed@example.com')
    end
  end
end
