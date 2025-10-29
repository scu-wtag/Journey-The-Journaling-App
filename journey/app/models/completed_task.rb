class CompletedTask < ApplicationRecord
  belongs_to :team
  belongs_to :task, optional: true
  belongs_to :assignee, class_name: 'User'

  scope :today, -> { where(completed_at: Time.zone.today.all_day) }
end
