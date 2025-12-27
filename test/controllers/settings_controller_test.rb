require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:alice)
  end

  test "show requires authentication" do
    delete session_path
    get settings_path
    assert_redirected_to new_session_path
  end

  test "show renders settings page" do
    get settings_path
    assert_response :success
  end

  test "update profile settings" do
    patch settings_path, params: {
      user: { name: "Updated Name" }
    }
    assert_redirected_to settings_path
    assert_equal "Updated Name", users(:alice).reload.name
  end

  test "update welcome email settings" do
    patch settings_path, params: {
      user: {
        welcome_email_enabled: true,
        welcome_email_subject: "New Subject",
        welcome_email_content: "New Content"
      }
    }

    assert_redirected_to settings_path
    user = users(:alice).reload
    assert user.welcome_email_enabled
    assert_equal "New Subject", user.welcome_email_subject
    assert_equal "New Content", user.welcome_email_content
  end

  test "update with invalid params" do
    patch settings_path, params: {
      user: { name: "" }
    }
    assert_response :unprocessable_entity
  end

  test "update_password with correct current password" do
    patch settings_password_path, params: {
      current_password: "password123",
      user: {
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }

    assert_redirected_to settings_path
    assert_match /Password changed/, flash[:notice]
    assert users(:alice).reload.authenticate("newpassword123")
  end

  test "update_password with incorrect current password" do
    patch settings_password_path, params: {
      current_password: "wrongpassword",
      user: {
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }

    assert_response :unprocessable_entity
  end

  test "update_password with invalid new password" do
    patch settings_password_path, params: {
      current_password: "password123",
      user: {
        password: "short",
        password_confirmation: "short"
      }
    }

    assert_response :unprocessable_entity
  end

  test "destroy account with correct password" do
    user = users(:alice)
    user_id = user.id

    delete settings_path, params: { password: "password123" }

    assert_redirected_to root_path
    assert_match /account has been deleted/, flash[:notice]
    assert_nil User.find_by(id: user_id)
  end

  test "destroy account with incorrect password" do
    delete settings_path, params: { password: "wrongpassword" }

    assert_response :unprocessable_entity
    assert User.exists?(users(:alice).id)
  end
end
