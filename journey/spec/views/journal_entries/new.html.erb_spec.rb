require "rails_helper"

RSpec.describe "journal_entries/new", type: :view do
  it "renders the form" do
    assign(:journal_entry, JournalEntry.new)
    render
    expect(rendered).to match(/<form/)
  end
end
