class Profile < ApplicationRecord
  belongs_to :user, inverse_of: :profile
  has_one_attached :picture
  before_validation :compose_phone

  private

  def compose_phone
    code = phone_country_code.to_s.strip
    local = phone_local.to_s.gsub(/\D/, '')
    self.phone = code.present? && local.present? ? "+#{code}#{local}" : nil
  end

  private

  def picture_type_and_size
    return unless picture.attached?

    if picture.blob.byte_size > 5.megabytes
      errors.add(:picture, "ist zu gross (max. 5 MB)")
    end

    acceptable = %w[image/jpeg image/png image/webp image/avif]
    unless acceptable.include?(picture.blob.content_type)
      errors.add(:picture, "muss JPEG, PNG, WebP oder AVIF sein")
    end
  end

end
