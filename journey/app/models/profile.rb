class Profile < ApplicationRecord
  belongs_to :user, inverse_of: :profile

  before_validation :compose_phone

  private

  def compose_phone
    code = phone_country_code.to_s.strip
    local = phone_local.to_s.gsub(/\D/, '')
    self.phone = code.present? && local.present? ? "+#{code}#{local}" : nil
  end
end
