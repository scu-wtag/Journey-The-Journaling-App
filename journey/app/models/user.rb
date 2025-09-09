class User < ApplicationRecord
  include Clearance::User

  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile

  ROLES = %w[guest member admin].freeze

  validates :name, presence: true   

  def role?(r)
    role == r.to_s
  end
end