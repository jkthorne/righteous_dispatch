require "test_helper"

class EmailTrackingFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
    @newsletter = @user.newsletters.create!(title: "Tracking Test", subject: "Test", status: :sent)
    @newsletter.content = "<p>Content with <a href='https://example.com'>link</a></p>"
    @newsletter.save!
    @subscriber = @user.subscribers.create!(email: "tracking#{SecureRandom.hex(4)}@example.com", status: :confirmed)
  end

  test "complete open tracking flow" do
    token = generate_tracking_token(newsletter: @newsletter, subscriber: @subscriber)
    initial_count = EmailEvent.count

    # Simulate email client loading tracking pixel
    get tracking_open_path(token: token)

    assert_response :success
    assert_equal "image/gif", response.content_type
    assert_equal initial_count + 1, EmailEvent.count

    event = EmailEvent.last
    assert_equal "open", event.event_type
    assert_equal @newsletter.id, event.newsletter_id
    assert_equal @subscriber.id, event.subscriber_id
  end

  test "open tracking is idempotent" do
    token = generate_tracking_token(newsletter: @newsletter, subscriber: @subscriber)

    # First open
    get tracking_open_path(token: token)
    initial_count = EmailEvent.count

    # Second open - should not create new event
    get tracking_open_path(token: token)
    assert_equal initial_count, EmailEvent.count
  end

  test "complete click tracking flow" do
    token = generate_tracking_token(newsletter: @newsletter, subscriber: @subscriber)
    target_url = "https://example.com/tracked-page"
    initial_count = EmailEvent.count

    # Simulate user clicking tracked link
    get tracking_click_path(token: token, url: target_url)

    assert_redirected_to target_url
    assert_equal initial_count + 1, EmailEvent.count

    event = EmailEvent.last
    assert_equal "click", event.event_type
    assert_equal target_url, event.metadata["url"]
  end

  test "multiple clicks are tracked separately" do
    token = generate_tracking_token(newsletter: @newsletter, subscriber: @subscriber)

    # Multiple clicks create multiple events
    get tracking_click_path(token: token, url: "https://example.com/page1")
    first_count = EmailEvent.clicks.count

    get tracking_click_path(token: token, url: "https://example.com/page2")
    assert_equal first_count + 1, EmailEvent.clicks.count
  end

  test "invalid token still allows graceful handling" do
    # Open with invalid token - returns gif, no event
    get tracking_open_path(token: "invalid")
    assert_response :success
    assert_equal "image/gif", response.content_type

    # Click with invalid token and URL - redirects to URL
    get tracking_click_path(token: "invalid", url: "https://example.com")
    assert_redirected_to "https://example.com"

    # Click with invalid token, no URL - redirects to root
    get tracking_click_path(token: "invalid")
    assert_redirected_to root_url
  end
end
