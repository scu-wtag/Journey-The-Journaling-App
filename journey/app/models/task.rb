class Task < ApplicationRecord
  belongs_to :team
  belongs_to :creator, class_name: 'User'
  belongs_to :assignee, class_name: 'User', optional: true
  belongs_to :journal_entry, optional: true
  has_many_attached :files

  enum :status, { todo: 0, in_progress: 1, done: 2 }, default: :todo

  validates :title, presence: true, length: { maximum: 180 }

  scope :assigned_to, ->(user) { where(assignee_id: user.id) }

  after_update_commit :track_done_completion,
                      if: -> { saved_change_to_status? && done? }

  before_destroy :ensure_completion_record

  private

  def track_done_completion
    CompletedTask.find_or_create_by!(task_id: id) do |ct|
      ct.team = team
      ct.assignee = fallback_assignee
      ct.completed_at = Time.current
    end
  end

  def ensure_completion_record
    return unless done?
    return if CompletedTask.exists?(task_id: id)

    CompletedTask.create!(
      team: team,
      task: self,
      assignee: fallback_assignee,
      completed_at: updated_at || Time.current,
    )
  end

  def fallback_assignee
    assignee || creator || team_member_fallback
  end

  def team_member_fallback
    if team.respond_to?(:users) && team.users.any?
      team.users.first
    elsif team.respond_to?(:members) && team.members.any?
      team.members.first
    else
      creator || assignee
    end
  end
end
