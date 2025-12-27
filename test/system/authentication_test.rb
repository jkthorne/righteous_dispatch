require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "visiting login page" do
    visit new_session_path

    assert_text "SIGN IN"
    assert_selector "input[name='email']"
    assert_selector "input[name='password']"
  end

  test "visiting registration page" do
    visit new_registration_path

    assert_text "REGISTER"
    assert_selector "form"
  end

  test "visiting password reset page" do
    visit new_password_path

    assert_text "RESET PASSWORD"
    assert_selector "input[name='email']"
  end

  test "login form submission" do
    user = users(:alice)

    visit new_session_path
    find("input[name='email']").fill_in with: user.email
    find("input[name='password']").fill_in with: "password123"
    find("input[type='submit']").click

    # Should redirect to dashboard on success
    assert_current_path dashboard_path
  end
end
