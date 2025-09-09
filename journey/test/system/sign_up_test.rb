require "application_system_test_case"

class SignUpTest < ApplicationSystemTestCase
  test "happy path: user signs up and lands on root" do
    visit "/signup"

    fill_in "Email", with: "alice@example.com"
    fill_in "Name", with: "Alice"
    fill_in "Password", with: "secret123"
    fill_in "Repeat password", with: "secret123"

    fill_in "Phone country code", with: "41", match: :first rescue nil
    fill_in "Phone (local)", with: "79 123 45 67", match: :first rescue nil
    fill_in "Phone (E.164)", with: "+41791234567", match: :first rescue nil
    fill_in "Date of birth", with: "2000-01-01" rescue nil
    (fill_in "Country", with: "CH" rescue fill_in("country", with: "CH")) rescue nil
    fill_in "Headquarters", with: "Zürich" rescue nil

    click_button "Sign Up"

    assert_current_path "/"
    user = User.find_by!(email: "alice@example.com")
    assert_equal "member", user.role
    assert user.profile.present?
    assert_equal "Zürich", user.profile.hq
    assert_equal "CH", user.profile.country
  end

  test "duplicate email is prevented" do
    User.create!(email: "dup@example.com", password: "pw12345", name: "Dupe")

    visit "/signup"
    fill_in "Email", with: "dup@example.com"
    fill_in "Name", with: "Someone"
    fill_in "Password", with: "secret123"
    fill_in "Repeat password", with: "secret123"
    click_button "Sign Up"

    refute_current_path "/"
    assert_text "has already been taken"
  end

  test "password confirmation mismatch shows error" do
    visit "/signup"
    fill_in "Email", with: "mismatch@example.com"
    fill_in "Name", with: "Mismatch"
    fill_in "Password", with: "secret123"
    fill_in "Repeat password", with: "different123"
    click_button "Sign Up"

    refute_current_path "/"
    assert_text "does not match confirmation"
  end

  test "missing required fields shows errors (name required)" do
    visit "/signup"
    fill_in "Email", with: "noname@example.com"
    fill_in "Password", with: "secret123"
    fill_in "Repeat password", with: "secret123"
    click_button "Sign Up"

    refute_current_path "/"
    assert_text "Name"
  end
end