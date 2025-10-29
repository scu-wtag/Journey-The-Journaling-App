module ProfileOptions
  extend ActiveSupport::Concern

  HEADQUARTERS = %w(ZRH DAC REM).freeze

  class_methods do
    def phone_country_options
      countries = ISO3166::Country.all

      options = countries.filter_map do |country|
        code = country.country_code.to_s
        next if code.blank?

        name = localized_country_name(country)
        next if name.blank?

        ["#{name} (+#{code})", code]
      end

      options.sort_by { |label, _| label }
    end

    def localized_country_name(country)
      country.translation(I18n.locale.to_s) ||
        country.common_name ||
        country.iso_short_name ||
        country.name
    end

    def headquarter_options
      HEADQUARTERS.map { |code| [I18n.t("users.hq.#{code.downcase}"), code] }
    end
  end
end
