class Profile < ApplicationRecord
  include ProfileOptions

  belongs_to :user

  HEADQUARTERS = %w[ZRH DAC REM].freeze
end
