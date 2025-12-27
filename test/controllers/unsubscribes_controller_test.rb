require "test_helper"

class UnsubscribesControllerTest < ActionDispatch::IntegrationTest
  test "show with valid token" do
    subscriber = subscribers(:confirmed_subscriber)
    get unsubscribe_path(token: subscriber.unsubscribe_token)
    assert_response :success
  end

  test "show with invalid token redirects" do
    get unsubscribe_path(token: "invalid_token")
    assert_redirected_to root_path
    assert_match /Invalid/, flash[:alert]
  end

  test "create unsubscribes subscriber" do
    subscriber = subscribers(:confirmed_subscriber)
    assert subscriber.confirmed?

    post unsubscribe_path(token: subscriber.unsubscribe_token)

    assert_redirected_to unsubscribe_path(token: subscriber.unsubscribe_token)
    assert subscriber.reload.unsubscribed?
    assert_match /successfully unsubscribed/, flash[:notice]
  end

  test "create with invalid token redirects" do
    post unsubscribe_path(token: "invalid_token")
    assert_redirected_to root_path
    assert_match /Invalid/, flash[:alert]
  end

  test "create with already unsubscribed shows message" do
    subscriber = subscribers(:unsubscribed_subscriber)

    post unsubscribe_path(token: subscriber.unsubscribe_token)

    assert_redirected_to unsubscribe_path(token: subscriber.unsubscribe_token)
    assert_match /already unsubscribed/, flash[:notice]
  end
end
