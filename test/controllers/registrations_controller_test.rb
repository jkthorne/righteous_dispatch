require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new renders registration form" do
    get new_registration_path
    assert_response :success
    assert_select "form"
  end

  test "new redirects when signed in" do
    sign_in_as users(:alice)
    get new_registration_path
    assert_redirected_to dashboard_path
  end

  test "create with valid params" do
    assert_difference "User.count", 1 do
      post registration_path, params: {
        user: {
          name: "New User",
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_redirected_to new_session_path
    assert_match /check your email/, flash[:notice]
  end

  test "create sends confirmation email" do
    assert_enqueued_emails 1 do
      post registration_path, params: {
        user: {
          name: "New User",
          email: "newuser2@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
  end

  test "create with invalid params" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        user: {
          name: "",
          email: "",
          password: "short"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "create with duplicate email" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        user: {
          name: "Duplicate",
          email: users(:alice).email,
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "create with mismatched password confirmation" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        user: {
          name: "New User",
          email: "mismatch@example.com",
          password: "password123",
          password_confirmation: "different123"
        }
      }
    end
    assert_response :unprocessable_entity
  end
end
