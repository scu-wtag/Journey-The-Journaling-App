FactoryBot.define do
  factory :membership do
    association :user
    association :team
    role { :member }
  end
end
