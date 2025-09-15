class User < ApplicationRecord
  include Clearance::User

  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile

  validates :name,  presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  enum :role, { guest: 0, member: 1, admin: 2 }, default: :member

  before_validation :downcase_email

  private

  def downcase_email
    self.email = email.to_s.downcase
  end
end
