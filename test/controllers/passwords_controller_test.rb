require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "new renders form" do
    get new_password_path
    assert_response :success
    assert_select "form"
  end

  test "new redirects when signed in" do
    sign_in_as users(:alice)
    get new_password_path
    assert_redirected_to dashboard_path
  end

  test "create sends reset email" do
    user = users(:alice)

    assert_enqueued_emails 1 do
      post password_path, params: { email: user.email }
    end

    assert_redirected_to new_session_path
    assert_match /receive password reset instructions/, flash[:notice]

    # Token should be generated
    assert_not_nil user.reload.password_reset_token
  end

  test "create with unknown email shows same message" do
    # Prevents email enumeration
    post password_path, params: { email: "unknown@example.com" }

    assert_redirected_to new_session_path
    assert_match /receive password reset instructions/, flash[:notice]
  end

  test "edit with valid token" do
    user = users(:charlie) # Has password_reset_token set
    get edit_password_path(token: user.password_reset_token)
    assert_response :success
    assert_select "form"
  end

  test "edit with invalid token" do
    get edit_password_path(token: "invalid_token")
    assert_redirected_to new_password_path
    assert_match /Invalid or expired/, flash[:alert]
  end

  test "edit with expired token" do
    user = users(:charlie)
    user.update!(password_reset_sent_at: 3.hours.ago)

    get edit_password_path(token: user.password_reset_token)
    assert_redirected_to new_password_path
    assert_match /Invalid or expired/, flash[:alert]
  end

  test "update resets password" do
    user = users(:charlie)

    patch password_path(token: user.password_reset_token), params: {
      user: {
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }

    assert_redirected_to new_session_path
    assert_match /password has been reset/, flash[:notice]

    # Token should be cleared
    assert_nil user.reload.password_reset_token
    assert_nil user.password_reset_sent_at

    # New password should work
    assert user.authenticate("newpassword123")
  end

  test "update with invalid password" do
    user = users(:charlie)

    patch password_path(token: user.password_reset_token), params: {
      user: {
        password: "short",
        password_confirmation: "short"
      }
    }

    assert_response :unprocessable_entity
    # Token should still be valid
    assert_not_nil user.reload.password_reset_token
  end

  test "update with mismatched confirmation" do
    user = users(:charlie)

    patch password_path(token: user.password_reset_token), params: {
      user: {
        password: "newpassword123",
        password_confirmation: "different123"
      }
    }

    assert_response :unprocessable_entity
  end
end
