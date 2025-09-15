class Profile < ApplicationRecord
  belongs_to :user, inverse_of: :profile, required: true
end
