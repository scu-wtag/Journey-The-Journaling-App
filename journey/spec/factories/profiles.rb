FactoryBot.define do
  factory :profile do
    association :user
    headquarters { 'ZRH' }
    country { 'CH' }
    phone_country_code { '41' }
    phone_local { '791234567' }
    phone { '+41791234567' }

    trait :with_profile_picture do
      after(:build) do |profile|
        fixture_path = Rails.root.join('spec/fixtures/files/cute.png')

        profile.picture.attach(
          io: File.open(fixture_path),
          filename: 'cute.png',
          content_type: 'image/png',
        )
      end
    end
  end
end
