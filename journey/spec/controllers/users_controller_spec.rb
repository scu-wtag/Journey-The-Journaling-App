require "rails_helper"

RSpec.describe "Sign up", type: :system do
  it "creates a new user" do
    visit "/signup"

    fill_in "Email", with: "newuser@example.com"
    fill_in "Name", with: "New User"
    fill_in "Password", with: "password"
    fill_in "Repeat password", with: "password"
    click_button "Sign Up"

    expect(page).to have_content("Journey")
    expect(User.find_by(email: "newuser@example.com")).to be_present
  end
end
