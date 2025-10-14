FactoryBot.define do
  factory :profile do
    association :user
    headquarters { 'ZRH' }
    country { 'CH' }
    phone_country_code { '41' }
    phone_local { '791234567' }
    phone { '+41791234567' }

    trait :with_profile_picture do
      picture { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/cute.png'), 'image/png') }
    end
  end
end
