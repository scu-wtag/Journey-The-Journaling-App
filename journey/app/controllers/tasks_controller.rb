class TasksController < ApplicationController
  before_action :require_login
  before_action :set_team, only: %i(index new create)
  before_action :set_task, only: %i(show edit update destroy)
  helper NavHelpers

  def index
    if @team
      authorize! :read, @team
      @tasks = @team.tasks.
               includes(:team, :assignee).
               order(created_at: :desc)
    else
      base = Task.assigned_to(current_user).
             where.not(status: :done).
             includes(:team, :creator).
             references(:team).
             order('teams.name ASC, tasks.status ASC, tasks.created_at DESC')

      @tasks_by_team = base.group_by(&:team)
      @team_counts = base.group(:team_id, :status).count
    end
  end

  def show
    authorize! :read, @task
  end

  def new
    authorize! :create, Task.new(team: @team)
    @task = @team.tasks.new(creator: current_user, assignee: current_user)
  end

  def edit
    authorize! :update, @task
  end

  def create
    @task = @team.tasks.new(task_params.merge(creator: current_user))
    authorize! :create, @task
    if @task.save
      task_created
    else
      task_failed
    end
  end

  def task_created
    redirect_to team_tasks_path(@team), notice: t('tasks.created', default: 'Task created')
  end

  def task_failed
    flash.now[:alert] = @task.errors.full_messages.to_sentence
    render :new, status: :unprocessable_content
  end

  def update
    authorize! :update, @task
    if @task.update(task_params)
      update_done
    else
      update_failed
    end
  end

  def update_done
    redirect_to task_path(@task), notice: t('tasks.updated', default: 'Task updated')
  end

  def update_failed
    flash.now[:alert] = @task.errors.full_messages.to_sentence
    render :edit, status: :unprocessable_content
  end

  def destroy
    authorize! :destroy, @task
    team = @task.team
    @task.destroy
    redirect_to team_tasks_path(team), notice: t('tasks.deleted', default: 'Task deleted')
  end

  private

  def task_params
    params.expect(task: %i(title notes status assignee_id due_on))
  end

  def set_team
    @team = Team.find(params[:team_id]) if params[:team_id].present?
  end

  def set_task
    @task = Task.find(params[:id])
  end
end
