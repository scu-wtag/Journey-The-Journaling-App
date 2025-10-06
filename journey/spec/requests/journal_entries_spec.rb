require 'rails_helper'

RSpec.describe 'JournalEntries', type: :request do
  let(:user) { create(:user) }

  before { sign_in(user) }

  describe 'GET /index' do
    it 'returns http success' do
      get journal_entries_path(locale: I18n.locale)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      entry = create(:journal_entry, user: user)
      get journal_entry_path(entry, locale: I18n.locale)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /new' do
    it 'returns http success' do
      get new_journal_entry_path(locale: I18n.locale)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /edit' do
    it 'returns http success' do
      entry = create(:journal_entry, user: user)
      get edit_journal_entry_path(entry, locale: I18n.locale)
      expect(response).to have_http_status(:success)
    end
  end
end
