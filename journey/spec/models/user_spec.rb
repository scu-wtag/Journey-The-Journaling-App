require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    describe 'associations' do
      it { is_expected.to have_one(:profile).dependent(:destroy) }
    end

    describe 'nested attributes' do
      it 'accepts nested attributes for profile' do
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
        user = build(:user)
        expect(user.role).to eq('member')
        expect(described_class.roles.keys).to match_array(%w(guest member admin))
      end
    end

    describe 'validations' do
      subject { create(:user) }

      it { is_expected.to validate_presence_of(:email) }
      it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
      it { is_expected.to validate_presence_of(:name) }
    end

    describe 'callbacks' do
      it 'downcases email before save' do
        user = build(:user, email: 'MiXeD@Example.COM')
        user.save!
        expect(user.reload.email).to eq('mixed@example.com')
      end
    end
  end
end
