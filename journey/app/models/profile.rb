class Profile < ApplicationRecord
  belongs_to :user
  # All fields optional for now (no validations here)
end