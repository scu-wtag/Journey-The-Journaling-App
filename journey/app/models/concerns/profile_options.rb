module ProfileOptions
  extend ActiveSupport::Concern

  HEADQUARTERS = %w[ZRH DAC REM].freeze

  class_methods do
    def phone_country_options
      ISO3166::Country.all
      .filter_map do |country|
        code = country.country_code
        next if code.blank?

        name = country.translation(I18n.locale.to_s) ||
        country.common_name ||
        country.iso_short_name ||
        country.name

        ["#{name} (+#{code})", code]
      end
      .sort_by(&:first)
    end

    def headquarter_options
      HEADQUARTERS.map { |code| [I18n.t("users.hq.#{code.downcase}"), code] }
    end
  end
end
