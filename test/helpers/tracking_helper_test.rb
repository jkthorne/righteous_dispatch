require "test_helper"

class TrackingHelperTest < ActionView::TestCase
  include TrackingHelper

  setup do
    @newsletter = newsletters(:sent_newsletter)
    @subscriber = subscribers(:confirmed_subscriber)
  end

  # Token generation
  test "tracking_token generates valid token" do
    token = tracking_token(newsletter: @newsletter, subscriber: @subscriber)

    assert_not_nil token
    assert token.is_a?(String)
    assert token.present?
  end

  test "tracking_token generates different tokens for different pairs" do
    other_subscriber = subscribers(:pending_subscriber)

    token1 = tracking_token(newsletter: @newsletter, subscriber: @subscriber)
    token2 = tracking_token(newsletter: @newsletter, subscriber: other_subscriber)

    assert_not_equal token1, token2
  end

  test "tracking_token can be verified" do
    token = tracking_token(newsletter: @newsletter, subscriber: @subscriber)
    data = Rails.application.message_verifier(:tracking).verified(token)

    assert_not_nil data
    assert_equal @newsletter.id, data["newsletter_id"]
    assert_equal @subscriber.id, data["subscriber_id"]
  end

  # Tracking pixel URL
  test "tracking_pixel_url generates url with token" do
    url = tracking_pixel_url(newsletter: @newsletter, subscriber: @subscriber)

    # URL format is /t/o/:token (token in path, not query param)
    assert_match %r{/t/o/}, url
    assert_match %r{/t/o/[A-Za-z0-9_=-]+}, url
  end

  # Tracked link URL
  test "tracked_link_url generates url with token and original url" do
    original_url = "https://example.com/page"
    url = tracked_link_url(newsletter: @newsletter, subscriber: @subscriber, url: original_url)

    # URL format is /t/c/:token?url=encoded_url
    assert_match %r{/t/c/}, url
    assert_match %r{/t/c/[A-Za-z0-9_=-]+}, url
    assert_match /url=/, url
  end

  # Link tracking in HTML
  test "track_links_in_html rewrites regular links" do
    html = '<a href="https://example.com/page">Click me</a>'
    result = track_links_in_html(html, newsletter: @newsletter, subscriber: @subscriber)

    assert_match %r{/t/c/}, result
    assert_no_match %r{href="https://example\.com/page"}, result
  end

  test "track_links_in_html handles multiple links" do
    html = '<a href="https://example.com/a">A</a> <a href="https://example.com/b">B</a>'
    result = track_links_in_html(html, newsletter: @newsletter, subscriber: @subscriber)

    assert_equal 2, result.scan(%r{/t/c/}).count
  end

  test "track_links_in_html skips mailto links" do
    html = '<a href="mailto:test@example.com">Email</a>'
    result = track_links_in_html(html, newsletter: @newsletter, subscriber: @subscriber)

    assert_match /mailto:test@example\.com/, result
    assert_no_match %r{/t/c/}, result
  end

  test "track_links_in_html skips tel links" do
    html = '<a href="tel:+1234567890">Call</a>'
    result = track_links_in_html(html, newsletter: @newsletter, subscriber: @subscriber)

    assert_match /tel:\+1234567890/, result
    assert_no_match %r{/t/c/}, result
  end

  test "track_links_in_html skips anchor links" do
    html = '<a href="#section">Jump</a>'
    result = track_links_in_html(html, newsletter: @newsletter, subscriber: @subscriber)

    assert_match /#section/, result
    assert_no_match %r{/t/c/}, result
  end

  test "track_links_in_html skips unsubscribe links" do
    html = '<a href="https://example.com/unsubscribe/token123">Unsubscribe</a>'
    result = track_links_in_html(html, newsletter: @newsletter, subscriber: @subscriber)

    assert_match /unsubscribe/, result
    assert_no_match %r{/t/c/}, result
  end

  test "track_links_in_html returns blank for blank input" do
    assert_nil track_links_in_html(nil, newsletter: @newsletter, subscriber: @subscriber)
    assert_equal "", track_links_in_html("", newsletter: @newsletter, subscriber: @subscriber)
  end

  test "track_links_in_html preserves non-link html" do
    html = '<p>Hello <strong>world</strong></p>'
    result = track_links_in_html(html, newsletter: @newsletter, subscriber: @subscriber)

    assert_match /<p>Hello <strong>world<\/strong><\/p>/, result
  end
end
