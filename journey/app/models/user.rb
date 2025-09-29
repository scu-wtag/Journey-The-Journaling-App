class User < ApplicationRecord
  include Clearance::User

  has_one :profile, dependent: :destroy, inverse_of: :user
  accepts_nested_attributes_for :profile, update_only: true

  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships

  enum :role, { guest: 0, member: 1, admin: 2 }, default: :member

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :locale, inclusion: { in: %w(en de) }
  validates :theme, inclusion: { in: %w(light dark) }

  before_validation :downcase_email

  private

  def downcase_email
    self.email = email.to_s.downcase
  end
end
