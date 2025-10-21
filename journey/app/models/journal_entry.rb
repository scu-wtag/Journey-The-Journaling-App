class JournalEntry < ApplicationRecord
  belongs_to :user

  has_rich_text :body
  has_rich_text :goals_for_tomorrow
  has_many_attached :files

  validates :title, presence: true, length: { maximum: 180 }
  validates :entry_date, presence: true
  validate  :time_range_valid
  validate  :acceptable_files

  private

  def time_range_valid
    return if time_from.blank? || time_to.blank?
    if time_to <= time_from
      errors.add(:time_to, I18n.t('journal.errors.time_to_after_time_from'))
    end
  end

  def acceptable_files
    return unless files.attached?

    allowed_types = %w[
      image/jpeg
      image/png
      application/pdf
      text/plain
    ]
    max_size = 10.megabytes

    files.each do |file|
      if file.byte_size > max_size
        errors.add(:files, 'must be smaller than 10 MB')
      end
      unless allowed_types.include?(file.content_type)
        errors.add(:files, 'must be a JPEG, PNG, PDF, or TXT file')
      end
    end
  end
end