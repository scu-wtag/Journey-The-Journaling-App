class JournalEntriesController < ApplicationController
  before_action :require_login
  before_action :set_entry, only: %i(show edit update destroy)
  before_action :authorize_entry!, only: %i(show edit update destroy)
  helper NavHelpers

  def index
    @journal_entries = current_user.journal_entries.order(entry_date: :desc)
  end

  def show; end

  def new
    @journal_entry = current_user.journal_entries.new(entry_date: Date.current)
  end

  def edit; end

  def create
    @journal_entry = current_user.journal_entries.new(entry_params)
    if @journal_entry.save
      redirect_to @journal_entry, notice: t('journal.flash.created')
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @journal_entry.update(entry_params)
      redirect_to @journal_entry, notice: t('journal.flash.updated')
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @journal_entry.destroy!
    redirect_to journal_entries_path, notice: t('journal.flash.deleted')
  rescue ActiveRecord::RecordNotDestroyed => error
    Rails.logger.warn("JournalEntry #{@journal_entry.id} not destroyed: #{error.message}")
    redirect_to @journal_entry, alert: t('journal.flash.delete_failed')
  end

  private

  def set_entry
    @journal_entry = JournalEntry.find(params[:id])
  end

  def authorize_entry!
    return if @journal_entry.user_id == current_user.id

    redirect_to journal_entries_path,
                alert: t('journal.flash.not_authorized')
  end

  def entry_params
    params.expect(
      journal_entry: [:title, :entry_date, :time_from, :time_to, :body, :goals_for_tomorrow, { files: [] }],
    )
  end
end
