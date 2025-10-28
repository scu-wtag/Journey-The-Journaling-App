class Task < ApplicationRecord
  belongs_to :team
  belongs_to :creator, class_name: 'User'
  belongs_to :assignee, class_name: 'User', optional: true
  belongs_to :journal_entry, optional: true
  has_many_attached :files

  enum :status, { todo: 0, in_progress: 1, done: 2 }, default: :todo

  validates :title, presence: true, length: { maximum: 180 }

  scope :assigned_to, ->(user) { where(assignee_id: user.id) }
end
