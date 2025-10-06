require 'rails_helper'

RSpec.describe 'journal_entries/edit', type: :view do
  it 'renders the form' do
    assign(:journal_entry, build_stubbed(:journal_entry))
    render
    expect(rendered).to match(/<form/)
  end
end
