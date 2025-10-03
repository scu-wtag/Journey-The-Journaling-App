class Profile < ApplicationRecord
  belongs_to :user, inverse_of: :profile
  validates :user_id, uniqueness: true
  has_one_attached :picture
  before_validation :compose_phone

  private

  def compose_phone
    code = phone_country_code.to_s.strip
    local = phone_local.to_s.gsub(/\D/, '')
    self.phone = code.present? && local.present? ? "+#{code}#{local}" : nil
  end

  def picture_type_and_size
    return unless picture.attached?

    errors.add(:picture, t('profile.update.failed', default: '')) if picture.blob.byte_size > 5.megabytes

    acceptable = %w(image/jpeg image/png image/webp image/avif)
    return if acceptable.include?(picture.blob.content_type)

    errors.add(:picture, t('profile.update.wrong_filetype', default: ''))
  end
  include ProfileOptions

  belongs_to :user

  HEADQUARTERS = %w[ZRH DAC REM].freeze
end
