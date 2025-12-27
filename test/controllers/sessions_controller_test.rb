require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "new renders login form" do
    get new_session_path
    assert_response :success
    assert_select "form"
  end

  test "new redirects when already signed in" do
    sign_in_as users(:alice)
    get new_session_path
    assert_redirected_to dashboard_path
  end

  test "create with valid credentials" do
    post session_path, params: {
      email: users(:alice).email,
      password: "password123"
    }
    assert_redirected_to dashboard_path
    assert_match /Welcome back/, flash[:notice]
  end

  test "create with invalid password" do
    post session_path, params: {
      email: users(:alice).email,
      password: "wrongpassword"
    }
    assert_response :unprocessable_entity
    assert_match /Invalid email or password/, flash[:alert]
  end

  test "create with unknown email" do
    post session_path, params: {
      email: "unknown@example.com",
      password: "password123"
    }
    assert_response :unprocessable_entity
    assert_match /Invalid email or password/, flash[:alert]
  end

  test "create with unconfirmed user" do
    post session_path, params: {
      email: users(:bob).email,
      password: "password123"
    }
    assert_redirected_to new_session_path
    assert_match /confirm your email/, flash[:alert]
  end

  test "create with remember me sets cookie" do
    post session_path, params: {
      email: users(:alice).email,
      password: "password123",
      remember_me: "1"
    }
    assert_redirected_to dashboard_path
    assert cookies[:remember_token].present?
  end

  test "create without remember me uses session" do
    post session_path, params: {
      email: users(:alice).email,
      password: "password123"
    }
    assert_redirected_to dashboard_path
    assert_nil cookies[:remember_token]
  end

  test "destroy signs out user" do
    sign_in_as users(:alice)
    delete session_path
    assert_redirected_to new_session_path
    assert_match /signed out/, flash[:notice]
  end

  test "destroy requires authentication" do
    delete session_path
    assert_redirected_to new_session_path
    assert_match /sign in/, flash[:alert]
  end

  test "create redirects to stored location after login" do
    # First, try to access a protected page
    get newsletters_path
    assert_redirected_to new_session_path

    # Then login
    post session_path, params: {
      email: users(:alice).email,
      password: "password123"
    }

    # Should redirect to the originally requested page
    assert_redirected_to newsletters_path
  end
end
