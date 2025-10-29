require 'rails_helper'

RSpec.describe Profile do
  describe 'associations' do
    it { is_expected.to belong_to(:user).inverse_of(:profile) }
  end

  describe 'validations' do
    it 'enforces uniqueness of user_id at app level' do
      user = create(:user)
      create(:profile, user: user)

      dup = build(:profile, user: user)
      expect(dup).not_to be_valid
      dup.validate
      expect(dup.errors[:user_id]).to be_present
    end
  end

  describe 'phone composition (before_validation)' do
    it 'builds +<code><local> when both parts present' do
      p = build(:profile, phone_country_code: '49', phone_local: '151 234 56 78')
      p.valid?
      expect(p.phone).to eq('+491512345678')
    end

    it 'sets phone to nil when parts missing' do
      p = build(:profile, phone_country_code: '', phone_local: '')
      p.valid?
      expect(p.phone).to be_nil
    end
  end

  describe 'picture validations hook exists' do
    it 'defines picture_type_and_size (activate validate to enforce)' do
      expect(described_class.private_instance_methods).to include(:picture_type_and_size)
    end
  end
end
