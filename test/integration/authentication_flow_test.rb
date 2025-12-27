require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  # Registration flow
  test "user can register with valid credentials" do
    get new_registration_path
    assert_response :success

    assert_difference "User.count", 1 do
      post registration_path, params: {
        user: {
          name: "New User",
          email: "newuser#{SecureRandom.hex(4)}@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
  end

  test "user receives confirmation email after registration" do
    # Uses deliver_later, so check enqueued jobs
    assert_enqueued_emails 1 do
      post registration_path, params: {
        user: {
          name: "Email User",
          email: "emailuser#{SecureRandom.hex(4)}@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
  end

  test "user can confirm email" do
    user = users(:bob) # Bob is unconfirmed
    assert_not user.confirmed?

    get confirm_email_path(token: user.confirmation_token)

    assert_redirected_to new_session_path
    assert user.reload.confirmed?
  end

  # Login flow
  test "confirmed user can login" do
    user = users(:alice)

    post session_path, params: {
      email: user.email,
      password: "password123"
    }

    assert_redirected_to dashboard_path
    follow_redirect!
    assert_response :success
  end

  test "unconfirmed user cannot login" do
    user = users(:bob)

    post session_path, params: {
      email: user.email,
      password: "password123"
    }

    assert_redirected_to new_session_path
  end

  test "user can logout" do
    sign_in(users(:alice))

    delete session_path

    # App redirects to login page after logout
    assert_redirected_to new_session_path
  end

  # Password reset flow
  test "user can request password reset" do
    user = users(:alice)

    # Uses deliver_later
    assert_enqueued_emails 1 do
      post password_path, params: { email: user.email }
    end

    assert user.reload.password_reset_token.present?
  end

  test "user can reset password with valid token" do
    user = users(:charlie) # Has reset token
    # Ensure token is fresh
    user.update!(password_reset_sent_at: Time.current)

    patch password_path, params: {
      token: user.password_reset_token,
      user: {
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }

    assert_redirected_to new_session_path
  end

  test "user can login with new password after reset" do
    user = users(:charlie)
    # Ensure token is fresh
    user.update!(password_reset_sent_at: Time.current)

    # Reset password
    patch password_path, params: {
      token: user.password_reset_token,
      user: {
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }

    # Login with new password
    post session_path, params: {
      email: user.email,
      password: "newpassword123"
    }

    assert_redirected_to dashboard_path
  end

  # Protected route access
  test "unauthenticated user is redirected from protected routes" do
    get newsletters_path
    assert_redirected_to new_session_path

    get subscribers_path
    assert_redirected_to new_session_path

    get dashboard_path
    assert_redirected_to new_session_path
  end

  test "authenticated user can access protected routes" do
    sign_in(users(:alice))

    get newsletters_path
    assert_response :success

    get subscribers_path
    assert_response :success

    get dashboard_path
    assert_response :success
  end
end
