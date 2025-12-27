require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers

  test "confirmation email has correct recipient" do
    user = users(:alice)
    email = UserMailer.confirmation(user)

    assert_equal [user.email], email.to
  end

  test "confirmation email has correct subject" do
    user = users(:alice)
    email = UserMailer.confirmation(user)

    assert_equal "Confirm your RighteousDispatch account", email.subject
  end

  test "confirmation email includes confirmation link" do
    user = users(:alice)
    email = UserMailer.confirmation(user)

    # Check the body contains the token (since URL helpers in tests may differ)
    assert_match user.confirmation_token, email.body.encoded
  end

  test "password_reset email has correct recipient" do
    user = users(:charlie)
    email = UserMailer.password_reset(user)

    assert_equal [user.email], email.to
  end

  test "password_reset email has correct subject" do
    user = users(:charlie)
    email = UserMailer.password_reset(user)

    assert_equal "Reset your RighteousDispatch password", email.subject
  end

  test "password_reset email includes reset link" do
    user = users(:charlie)
    email = UserMailer.password_reset(user)

    # Check the body contains the token
    assert_match user.password_reset_token, email.body.encoded
  end
end
