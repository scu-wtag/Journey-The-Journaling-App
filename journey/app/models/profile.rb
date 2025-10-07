class Profile < ApplicationRecord
  include ProfileOptions

  HEADQUARTERS = %w[ZRH DAC REM].freeze
  ALLOWED_IMAGE_TYPES = %w[image/jpeg image/png image/webp image/avif].freeze

  belongs_to :user, inverse_of: :profile
  validates :user_id, uniqueness: true

  has_one_attached :picture

  validates :picture, attached: true,
                      content_type: { in: ALLOWED_IMAGE_TYPES, message: I18n.t("profiles.update.wrong_filetype") },
                      size: { less_than_or_equal_to: 5.megabytes, message: I18n.t("profiles.update.failed") }

  validates :headquarters, inclusion: { in: HEADQUARTERS }

  before_validation :compose_phone

  private

  def compose_phone
    code  = phone_country_code.to_s.strip.gsub(/\D/, "")
    local = phone_local.to_s.gsub(/\D/, "")
    self.phone = code.present? && local.present? ? "+#{code}#{local}" : nil
  end
end
