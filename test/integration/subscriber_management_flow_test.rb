require "test_helper"

class SubscriberManagementFlowTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:alice))
  end

  test "complete subscriber lifecycle" do
    # Create subscriber
    assert_difference "Subscriber.count", 1 do
      post subscribers_path, params: {
        subscriber: {
          email: "lifecycle@example.com",
          first_name: "Test",
          last_name: "User"
        }
      }
    end

    subscriber = Subscriber.find_by(email: "lifecycle@example.com")
    assert_redirected_to subscribers_path

    # Edit subscriber
    get edit_subscriber_path(subscriber)
    assert_response :success

    patch subscriber_path(subscriber), params: {
      subscriber: { first_name: "Updated" }
    }
    assert_redirected_to subscribers_path
    assert_equal "Updated", subscriber.reload.first_name

    # Delete subscriber
    assert_difference "Subscriber.count", -1 do
      delete subscriber_path(subscriber)
    end
    assert_redirected_to subscribers_path
  end

  test "subscriber filtering by status" do
    get subscribers_path, params: { status: "confirmed" }
    assert_response :success

    get subscribers_path, params: { status: "pending" }
    assert_response :success

    get subscribers_path, params: { status: "unsubscribed" }
    assert_response :success
  end

  test "subscriber filtering by tag" do
    tag = tags(:tech)

    get subscribers_path, params: { tag: tag.id }
    assert_response :success
  end

  test "subscriber import page accessible" do
    get import_subscribers_path
    assert_response :success
  end

  test "subscriber tagging through edit" do
    subscriber = subscribers(:confirmed_subscriber)
    tag = tags(:news)

    patch subscriber_path(subscriber), params: {
      subscriber: { tag_ids: [tag.id] }
    }

    assert_redirected_to subscribers_path
    assert_includes subscriber.reload.tags, tag
  end
end
