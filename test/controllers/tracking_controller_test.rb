require "test_helper"

class TrackingControllerTest < ActionDispatch::IntegrationTest
  # Open tracking
  test "open returns transparent gif" do
    token = generate_tracking_token(
      newsletter: newsletters(:sent_newsletter),
      subscriber: subscribers(:confirmed_subscriber)
    )

    get tracking_open_path(token: token)

    assert_response :success
    assert_equal "image/gif", response.content_type
  end

  test "open with valid token records event" do
    # Create a new newsletter and subscriber for this test to avoid fixture conflicts
    user = users(:alice)
    newsletter = user.newsletters.create!(title: "Track Test Newsletter", subject: "Test", status: :sent)
    newsletter.content = "<p>Content</p>"
    newsletter.save!

    subscriber = user.subscribers.create!(email: "tracktest@example.com", status: :confirmed)

    token = generate_tracking_token(newsletter: newsletter, subscriber: subscriber)
    initial_count = EmailEvent.count

    get tracking_open_path(token: token)

    assert_equal initial_count + 1, EmailEvent.count
    event = EmailEvent.order(created_at: :desc).first
    assert_equal "open", event.event_type
    assert_equal newsletter.id, event.newsletter_id
    assert_equal subscriber.id, event.subscriber_id
  end

  test "open with invalid token still returns gif" do
    get tracking_open_path(token: "invalid_token")

    assert_response :success
    assert_equal "image/gif", response.content_type
  end

  test "open records ip and user agent" do
    # Create fresh newsletter and subscriber for this test
    user = users(:alice)
    newsletter = user.newsletters.create!(title: "UA Test Newsletter", subject: "Test", status: :sent)
    newsletter.content = "<p>Content</p>"
    newsletter.save!

    subscriber = user.subscribers.create!(email: "uatest@example.com", status: :confirmed)

    token = generate_tracking_token(newsletter: newsletter, subscriber: subscriber)

    get tracking_open_path(token: token),
        headers: { "User-Agent" => "TestBrowser/1.0" }

    event = EmailEvent.where(newsletter: newsletter, subscriber: subscriber).first
    assert_not_nil event, "Expected an EmailEvent to be created"
    assert_not_nil event.ip_address
    assert_equal "TestBrowser/1.0", event.user_agent
  end

  # Click tracking
  test "click redirects to url" do
    token = generate_tracking_token(
      newsletter: newsletters(:sent_newsletter),
      subscriber: subscribers(:confirmed_subscriber)
    )

    get tracking_click_path(token: token, url: "https://example.com/link")

    assert_redirected_to "https://example.com/link"
  end

  test "click with valid token records event" do
    # Create fresh newsletter and subscriber for this test
    user = users(:alice)
    newsletter = user.newsletters.create!(title: "Click Test Newsletter", subject: "Test", status: :sent)
    newsletter.content = "<p>Content</p>"
    newsletter.save!

    subscriber = user.subscribers.create!(email: "clicktest@example.com", status: :confirmed)

    token = generate_tracking_token(newsletter: newsletter, subscriber: subscriber)
    url = "https://example.com/tracked"
    initial_count = EmailEvent.count

    get tracking_click_path(token: token, url: url)

    assert_equal initial_count + 1, EmailEvent.count
    event = EmailEvent.order(created_at: :desc).first
    assert_equal "click", event.event_type
    assert_equal url, event.metadata["url"]
  end

  test "click with invalid token still redirects to url" do
    # Invalid token should still redirect to URL (better UX), just not record the click
    get tracking_click_path(token: "invalid", url: "https://example.com")

    assert_redirected_to "https://example.com"
  end

  test "click with invalid token and no url redirects to root" do
    get tracking_click_path(token: "invalid")

    assert_redirected_to root_url
  end

  test "click without url redirects to root" do
    token = generate_tracking_token(
      newsletter: newsletters(:sent_newsletter),
      subscriber: subscribers(:confirmed_subscriber)
    )

    get tracking_click_path(token: token)

    assert_redirected_to root_url
  end

  test "click allows external hosts" do
    token = generate_tracking_token(
      newsletter: newsletters(:sent_newsletter),
      subscriber: subscribers(:confirmed_subscriber)
    )

    get tracking_click_path(token: token, url: "https://external-site.com/page")

    assert_redirected_to "https://external-site.com/page"
  end
end
