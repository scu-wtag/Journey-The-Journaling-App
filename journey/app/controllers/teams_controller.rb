class TeamsController < ApplicationController
  before_action :require_login
  helper NavHelpers

  def index
    authorize! :read, Team
    @teams = current_user.teams.order(:name)
  end

  def show
    @team = Team.find(params[:id])
    authorize! :read, @team

    @memberships = @team.memberships.includes(:user).order('users.name ASC')
    @membership = @team.memberships.find_by(user_id: current_user.id)

    if defined?(Task)
      @assigned_counts =
        @team.tasks.
        where.not(status: :done).
        where.not(assignee_id: nil).
        group(:assignee_id).
        count

      @done_today_counts = if defined?(CompletedTask)
                             CompletedTask.where(team: @team, completed_at: Time.zone.today.all_day).
                               group(:assignee_id).
                               count
                           else
                             @team.tasks.where(status: :done, updated_at: Time.zone.today.all_day).
                               group(:assignee_id).
                               count
                           end
    else
      @assigned_counts = {}
      @done_today_counts = {}
    end
  end

  def new
    authorize! :create, Team
    @team = Team.new
  end

  def create
    authorize! :create, Team
    @team = Team.new(team_params)
    ActiveRecord::Base.transaction do
      @team.save!
      Membership.create!(team: @team, user: current_user, role: :admin)
    end
    redirect_to @team, notice: t('teams.created', default: 'Team created')
  rescue ActiveRecord::RecordInvalid => error
    flash.now[:alert] = error.record.errors.full_messages.to_sentence
    render :new, status: :unprocessable_content
  end

  private

  def team_params
    params.expect(team: [:name])
  end
end
