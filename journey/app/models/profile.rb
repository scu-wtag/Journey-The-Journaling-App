class Profile < ApplicationRecord
  belongs_to :user
  HEADQUARTERS = %w(ZRH DAC REM).freeze
  PHONE_COUNTRY_CODES = {
    ch: '41',
    de: '49',
    at: '43',
    sep: '---',
    uk: '44',
    us: '1',
    jp: '81',
    au: '61',
  }.freeze

  def self.phone_country_options
    PHONE_COUNTRY_CODES.map do |key, code|
      [I18n.t("users.new.phone_countries.#{key}"), code]
    end
  end

  def self.headquarter_options
    HEADQUARTERS.map { |code| [I18n.t("users.hq.#{code.downcase}"), code] }
  end
end
