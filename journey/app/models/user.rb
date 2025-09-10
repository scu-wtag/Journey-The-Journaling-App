class User < ApplicationRecord
  include Clearance::User

  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile

  validates :name, presence: true

  enum :role, { guest: 0, member: 1, admin: 2 }, default: :member
end
