require 'rails_helper'

RSpec.describe 'journal_entries/show', type: :view do
  it 'renders title' do
    assign(:journal_entry, build_stubbed(:journal_entry, title: 'My day'))
    render
    expect(rendered).to include('My day')
  end
end
