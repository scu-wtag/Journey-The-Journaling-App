class JournalEntry < ApplicationRecord
  belongs_to :user

  has_rich_text :body
  has_rich_text :goals_for_tomorrow
  has_many_attached :files

  validates :title, presence: true, length: { maximum: 180 }
  validates :entry_date, presence: true
  validate :time_range_valid

  private

  def time_range_valid
    return if time_from.blank? || time_to.blank?

    errors.add(:time_to, 'must be later than start time') if time_to <= time_from
  end
end
