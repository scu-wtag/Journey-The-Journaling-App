FactoryBot.define do
  factory :profile do
    phone_country_code { '41' }
    phone_local { '79 123 45 67' }
    birthday { Date.new(2000, 1, 1) }
    country { 'CH' }
    headquarters { 'Zurich' }
    association :user
  end
end
