FactoryBot.define do
  factory :profile do
    association :user
    headquarters { 'ZRH' }
    country { 'CH' }
    phone_country_code { '41' }
    phone_local { '791234567' }
    phone { '+41791234567' }

    picture { Rack::Test::UploadedFile.new('spec/fixtures/cute.png', 'image/png') }
  end
end
