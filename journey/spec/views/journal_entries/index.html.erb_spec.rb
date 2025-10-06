require 'rails_helper'

RSpec.describe 'journal_entries/index', type: :view do
  it 'renders a list' do
    assign(:journal_entries,
           [build_stubbed(:journal_entry, title: 'A'), build_stubbed(:journal_entry, title: 'B')])
    render
    expect(rendered).to include('A').and include('B')
  end
end
