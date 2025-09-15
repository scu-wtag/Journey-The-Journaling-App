class User < ApplicationRecord
  include Clearance::User

  has_one :profile, dependent: :destroy, inverse_of: :user

  # war ohne update_only –> Spec verlangt update_only: true
  accepts_nested_attributes_for :profile, update_only: true

  # damit die Team-Tests und SessionsController#url_after_create funktionieren:
  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships

  validates :name,  presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  enum :role, { guest: 0, member: 1, admin: 2 }, default: :member

  before_validation :downcase_email

  private

  def downcase_email
    self.email = email.to_s.downcase
  end
end
