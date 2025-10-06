FactoryBot.define do
  factory :journal_entry do
    association :user
    title { 'My day' }
    entry_date { Date.current }
    time_from { '09:00' }
    time_to { '17:00' }
    body { 'Did some work' }
    goals_for_tomorrow { 'Do more work' }
  end
end
