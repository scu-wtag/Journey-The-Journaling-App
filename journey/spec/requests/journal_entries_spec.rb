# spec/requests/journal_entries_spec.rb
require 'rails_helper'

RSpec.describe 'JournalEntries', type: :request do
  let(:user) { create(:user) }

  before do
    I18n.with_locale = :en
    sign_in_as(user)
  end

  describe 'GET /journal_entries' do
    it 'lists only own entries' do
      create(:journal_entry, user: user, title: 'Mine', entry_date: Time.zone.today)
      create(:journal_entry, title: 'Other', entry_date: Date.yesterday)

      get journal_entries_path, params: loc
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Mine')
      expect(response.body).not_to include('Other')
    end
  end

  describe 'POST /journal_entries' do
    let(:valid_params) do
      {
        journal_entry: {
          title: 'My day',
          entry_date: Date.current,
          time_from: '09:00',
          time_to: '17:00',
          body: '<div>Did some work</div>',
          goals_for_tomorrow: 'Ship it',
        },
      }
    end

    it 'creates an entry and redirects with notice' do
      expect do
        post journal_entries_path, params: loc(valid_params)
      end.to change(JournalEntry, :count).by(1)

      entry = JournalEntry.order(:created_at).last
      expect(entry.user_id).to eq(user.id)
      expect(response).to redirect_to(journal_entry_path(entry, loc))
      follow_redirect!
      expect(response.body).to include('My day')
    end

    it 'ignores user_id from params' do
      attacker = create(:user)
      bad = valid_params.deep_merge(journal_entry: { user_id: attacker.id })

      post journal_entries_path, params: loc(bad)
      entry = JournalEntry.order(:created_at).last
      expect(entry.user_id).to eq(user.id)
    end

    it 'returns 422 when invalid' do
      bad = valid_params.deep_merge(journal_entry: { title: '' })
      expect do
        post journal_entries_path, params: loc(bad)
      end.not_to change(JournalEntry, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'uploads multiple attachments' do
      file1 = upload('spec/fixtures/files/test.txt', 'text/plain')
      file2 = upload('spec/fixtures/files/test.png', 'image/png')

      params = valid_params.deep_merge(journal_entry: { files: [file1, file2] })
      post journal_entries_path, params: loc(params)

      entry = JournalEntry.order(:created_at).last
      expect(entry.files.count).to eq(2)
    end
  end

  describe 'PATCH /journal_entries/:id' do
    let!(:entry) { create(:journal_entry, user: user, title: 'Old') }

    it 'updates own entry' do
      patch journal_entry_path(entry, loc), params: loc(journal_entry: { title: 'New' })
      expect(response).to redirect_to(journal_entry_path(entry, loc))
      expect(entry.reload.title).to eq('New')
    end

    it 'returns 422 on invalid update' do
      patch journal_entry_path(entry, loc), params: loc(journal_entry: { title: '' })
      expect(response).to have_http_status(:unprocessable_content)
      expect(entry.reload.title).to eq('Old')
    end
  end

  describe 'DELETE /journal_entries/:id' do
    it 'deletes own entry' do
      entry = create(:journal_entry, user: user)
      expect do
        delete journal_entry_path(entry, loc)
      end.to change(JournalEntry, :count).by(-1)
      expect(response).to redirect_to(journal_entries_path(loc))
    end
  end

  describe 'authorization' do
    let(:other_user) { create(:user) }
    let!(:foreign_entry) { create(:journal_entry, user: other_user, title: 'Secret') }

    it 'redirects on SHOW' do
      get journal_entry_path(foreign_entry, loc)
      expect(response).to redirect_to(journal_entries_path(loc))
      expect(flash[:alert]).to eq(I18n.t('journal.flash.not_authorized'))
    end

    it 'redirects on EDIT' do
      get edit_journal_entry_path(foreign_entry, loc)
      expect(response).to redirect_to(journal_entries_path(loc))
    end

    it 'blocks UPDATE' do
      patch journal_entry_path(foreign_entry, loc), params: loc(journal_entry: { title: 'Hacked' })
      expect(response).to redirect_to(journal_entries_path(loc))
      expect(foreign_entry.reload.title).to eq('Secret')
    end

    it 'blocks DELETE' do
      expect do
        delete journal_entry_path(foreign_entry, loc)
      end.not_to change(JournalEntry, :count)
      expect(response).to redirect_to(journal_entries_path(loc))
    end
  end
end
