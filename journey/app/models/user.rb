class User < ApplicationRecord
  include Clearance::User

  attr_accessor :password_confirmation

  has_one :profile, dependent: :destroy, inverse_of: :user
  accepts_nested_attributes_for :profile, update_only: true

  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships

  has_many :journal_entries, dependent: :destroy

  validates :name, presence: true
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, confirmation: true, if: -> { password.present? }

  enum :role, { guest: 0, member: 1, admin: 2 }, default: :member

  before_validation :normalize_email!
  before_validation :normalize_profile_phone!, if: -> { profile.present? }
  validate :guard_duplicate_email!, on: :create

  private

  def normalize_email!
    self.email = email.to_s.strip.downcase
  end

  def normalize_profile_phone!
    code = profile.phone_country_code.to_s.strip.gsub(/\D/, '')
    local = profile.phone_local.to_s.gsub(/\D/, '')
    profile.phone = code.present? && local.present? ? "+#{code}#{local}" : nil
  end

  def guard_duplicate_email!
    return if email.blank?

    already = self.class.where('LOWER(email) = ?', email.downcase)
    already = already.where.not(id: id) if persisted?
    errors.add(:email, :taken) if already.exists?
  end
end
