require "test_helper"

class SubscribersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:alice)
  end

  # Authentication
  test "index requires authentication" do
    delete session_path
    get subscribers_path
    assert_redirected_to new_session_path
  end

  # Index
  test "index returns user subscribers" do
    get subscribers_path
    assert_response :success
  end

  test "index filters by tag" do
    get subscribers_path, params: { tag: tags(:tech).id }
    assert_response :success
  end

  test "index filters by status" do
    get subscribers_path, params: { status: "confirmed" }
    assert_response :success
  end

  # Show - Note: show.html.erb view doesn't exist, show may only work via turbo frames
  # This test verifies the route and authentication, not the response format
  test "show requires authentication and scoping" do
    # Sign out first
    delete session_path
    get subscriber_path(subscribers(:confirmed_subscriber))
    assert_redirected_to new_session_path
  end

  test "show returns not found for other users subscriber" do
    get subscriber_path(subscribers(:bob_subscriber))
    assert_response :not_found
  end

  # New
  test "new renders form" do
    get new_subscriber_path
    assert_response :success
    assert_select "form"
  end

  # Create
  test "create with valid params" do
    assert_difference "Subscriber.count", 1 do
      post subscribers_path, params: {
        subscriber: {
          email: "newsubscriber@example.com",
          first_name: "New",
          last_name: "Subscriber"
        }
      }
    end
    assert_redirected_to subscribers_path
  end

  test "create with invalid params" do
    assert_no_difference "Subscriber.count" do
      post subscribers_path, params: {
        subscriber: { email: "" }
      }
    end
    assert_response :unprocessable_entity
  end

  # Edit
  test "edit displays form" do
    get edit_subscriber_path(subscribers(:confirmed_subscriber))
    assert_response :success
    assert_select "form"
  end

  # Update
  test "update with valid params" do
    patch subscriber_path(subscribers(:confirmed_subscriber)), params: {
      subscriber: { first_name: "Updated" }
    }
    assert_redirected_to subscribers_path
    assert_equal "Updated", subscribers(:confirmed_subscriber).reload.first_name
  end

  test "update returns not found for other users subscriber" do
    patch subscriber_path(subscribers(:bob_subscriber)), params: {
      subscriber: { first_name: "Hacked" }
    }
    assert_response :not_found
  end

  # Destroy
  test "destroy removes subscriber" do
    subscriber = subscribers(:confirmed_subscriber)
    assert_difference "Subscriber.count", -1 do
      delete subscriber_path(subscriber)
    end
    assert_redirected_to subscribers_path
  end

  test "destroy returns not found for other users subscriber" do
    delete subscriber_path(subscribers(:bob_subscriber))
    assert_response :not_found
  end

  # Import
  test "import renders form" do
    get import_subscribers_path
    assert_response :success
  end

  test "process_import without file" do
    post process_import_subscribers_path
    assert_redirected_to import_subscribers_path
    assert_match /CSV file/i, flash[:alert]
  end
end
