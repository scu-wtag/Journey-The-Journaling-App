require 'rails_helper'

RSpec.describe JournalEntry do
  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_length_of(:title).is_at_most(180) }

  it { is_expected.to validate_presence_of(:entry_date) }

  describe 'time_range_valid' do
    let(:entry) { build(:journal_entry, time_from: '10:00', time_to: '09:00') }

    it 'adds error when time_to <= time_from' do
      expect(entry).not_to be_valid
      expect(entry.errors[:time_to]).to include('must be later than start time')
    end

    it 'accepts empty timeframes' do
      e = build(:journal_entry, time_from: nil, time_to: nil)
      expect(e).to be_valid
    end

    it 'accepts the accepted area' do
      e = build(:journal_entry, time_from: '09:00', time_to: '17:00')
      expect(e).to be_valid
    end
  end
end
