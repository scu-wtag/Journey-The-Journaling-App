require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "email must be unique (validation)" do
    User.create!(email: "unique@example.com", password: "pw12345", name: "A")
    u = User.new(email: "unique@example.com", password: "pw12345", name: "B")
    assert_not u.valid?
    assert_includes u.errors[:email], "has already been taken"
  end

  test "default role is member" do
    u = User.create!(email: "role@example.com", password: "pw12345", name: "Roley")
    assert_equal "member", u.role
  end
end