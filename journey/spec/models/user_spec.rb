require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_one(:profile).dependent(:destroy) }
    it { is_expected.to accept_nested_attributes_for(:profile) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }

    subject { described_class.new(name: "Someone", email: "unique@example.com", password: "secret") }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe "enums" do
    it do
      is_expected.to define_enum_for(:role)
        .with_values(guest: 0, member: 1, admin: 2)
        .backed_by_column_of_type(:integer)
    end

    it "defaults role to member" do
      u = described_class.new
      expect(u.role).to eq("member")
    end
  end
end
