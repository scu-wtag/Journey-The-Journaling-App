require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to allow_value(nil).for(:phone_country_code) }
    it { is_expected.to allow_value(nil).for(:phone_local) }
    it { is_expected.to allow_value(nil).for(:country) }
    it { is_expected.to allow_value(nil).for(:headquarters) }
  end
end