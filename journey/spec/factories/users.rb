FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { 'Testy Tester' }
    password { 'password123' }
    role { :member }

    trait :guest do
      role { :guest }
    end

    trait :member do
      role { :member }
    end

    trait :admin do
      role { :admin }
    end

    after(:build) do |user|
      user.build_profile if user.profile.nil?
    end
  end
end
