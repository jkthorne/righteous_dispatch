require "test_helper"

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  test "new renders form" do
    get new_confirmation_path
    assert_response :success
    assert_select "form"
  end

  test "new redirects when signed in" do
    sign_in_as users(:alice)
    get new_confirmation_path
    assert_redirected_to dashboard_path
  end

  test "create resends confirmation for unconfirmed user" do
    user = users(:bob) # Unconfirmed user

    assert_enqueued_emails 1 do
      post confirmation_path, params: { email: user.email }
    end

    assert_redirected_to new_session_path
    assert_match /confirmation instructions/, flash[:notice]
  end

  test "create does not send email for confirmed user" do
    user = users(:alice) # Already confirmed

    assert_no_enqueued_emails do
      post confirmation_path, params: { email: user.email }
    end

    # Still shows success message to prevent enumeration
    assert_redirected_to new_session_path
  end

  test "create with unknown email shows same message" do
    # Prevents email enumeration
    post confirmation_path, params: { email: "unknown@example.com" }

    assert_redirected_to new_session_path
    assert_match /confirmation instructions/, flash[:notice]
  end

  test "show confirms user" do
    user = users(:bob)
    assert_not user.confirmed?

    get confirm_email_path(token: user.confirmation_token)

    assert_redirected_to new_session_path
    assert_match /email has been confirmed/, flash[:notice]
    assert user.reload.confirmed?
    assert_nil user.confirmation_token
  end

  test "show with invalid token" do
    get confirm_email_path(token: "invalid_token")

    assert_redirected_to new_session_path
    assert_match /Invalid or expired/, flash[:alert]
  end
end
