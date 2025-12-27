require "test_helper"

class EmailEventTest < ActiveSupport::TestCase
  # Validations
  test "valid email event" do
    event = EmailEvent.new(
      newsletter: newsletters(:sent_newsletter),
      subscriber: subscribers(:pending_subscriber),
      event_type: EmailEvent::OPEN
    )
    assert event.valid?
  end

  test "event_type presence required" do
    event = EmailEvent.new(
      newsletter: newsletters(:sent_newsletter),
      subscriber: subscribers(:pending_subscriber)
    )
    assert_not event.valid?
    assert_includes event.errors[:event_type], "can't be blank"
  end

  test "event_type inclusion validation" do
    event = EmailEvent.new(
      newsletter: newsletters(:sent_newsletter),
      subscriber: subscribers(:pending_subscriber),
      event_type: "invalid"
    )
    assert_not event.valid?
    assert_includes event.errors[:event_type], "is not included in the list"
  end

  test "valid event types" do
    EmailEvent::EVENT_TYPES.each do |type|
      event = EmailEvent.new(
        newsletter: newsletters(:sent_newsletter),
        subscriber: subscribers(:pending_subscriber),
        event_type: type
      )
      assert event.valid?, "#{type} should be valid"
    end
  end

  # Constants
  test "event type constants defined" do
    assert_equal "open", EmailEvent::OPEN
    assert_equal "click", EmailEvent::CLICK
    assert_equal "bounce", EmailEvent::BOUNCE
    assert_equal "complaint", EmailEvent::COMPLAINT
  end

  # Associations
  test "belongs to newsletter" do
    assert_equal newsletters(:sent_newsletter), email_events(:sent_open).newsletter
  end

  test "belongs to subscriber" do
    assert_equal subscribers(:confirmed_subscriber), email_events(:sent_open).subscriber
  end

  # Scopes
  test "opens scope" do
    opens = EmailEvent.opens
    assert_includes opens, email_events(:sent_open)
    assert_not_includes opens, email_events(:sent_click)
  end

  test "clicks scope" do
    clicks = EmailEvent.clicks
    assert_includes clicks, email_events(:sent_click)
    assert_not_includes clicks, email_events(:sent_open)
  end

  test "bounces scope" do
    # Create a bounce event for testing
    bounce = EmailEvent.create!(
      newsletter: newsletters(:sent_newsletter),
      subscriber: subscribers(:pending_subscriber),
      event_type: EmailEvent::BOUNCE
    )
    bounces = EmailEvent.bounces
    assert_includes bounces, bounce
    assert_not_includes bounces, email_events(:sent_open)
  end

  test "complaints scope" do
    complaint = EmailEvent.create!(
      newsletter: newsletters(:sent_newsletter),
      subscriber: subscribers(:pending_subscriber),
      event_type: EmailEvent::COMPLAINT
    )
    complaints = EmailEvent.complaints
    assert_includes complaints, complaint
    assert_not_includes complaints, email_events(:sent_open)
  end

  test "for_newsletter scope" do
    events = EmailEvent.for_newsletter(newsletters(:sent_newsletter))
    assert_includes events, email_events(:sent_open)
    assert_includes events, email_events(:sent_click)
  end

  # Class methods
  test "record_open creates event" do
    newsletter = newsletters(:draft_newsletter)
    subscriber = subscribers(:confirmed_subscriber)

    assert_difference "EmailEvent.count", 1 do
      EmailEvent.record_open(
        newsletter: newsletter,
        subscriber: subscriber,
        ip_address: "10.0.0.1",
        user_agent: "TestAgent"
      )
    end

    event = EmailEvent.last
    assert_equal EmailEvent::OPEN, event.event_type
    assert_equal "10.0.0.1", event.ip_address
    assert_equal "TestAgent", event.user_agent
  end

  test "record_open is idempotent for same newsletter and subscriber" do
    newsletter = newsletters(:sent_newsletter)
    subscriber = subscribers(:confirmed_subscriber)

    # Already has an open event from fixtures
    assert_no_difference "EmailEvent.count" do
      EmailEvent.record_open(
        newsletter: newsletter,
        subscriber: subscriber,
        ip_address: "new-ip",
        user_agent: "NewAgent"
      )
    end
  end

  test "record_open allows different subscribers" do
    newsletter = newsletters(:sent_newsletter)

    assert_difference "EmailEvent.count", 1 do
      EmailEvent.record_open(
        newsletter: newsletter,
        subscriber: subscribers(:pending_subscriber),
        ip_address: "10.0.0.2"
      )
    end
  end

  test "record_click creates event" do
    newsletter = newsletters(:draft_newsletter)
    subscriber = subscribers(:confirmed_subscriber)

    assert_difference "EmailEvent.count", 1 do
      EmailEvent.record_click(
        newsletter: newsletter,
        subscriber: subscriber,
        url: "https://example.com/link",
        ip_address: "10.0.0.1",
        user_agent: "TestAgent"
      )
    end

    event = EmailEvent.last
    assert_equal EmailEvent::CLICK, event.event_type
    assert_equal({ "url" => "https://example.com/link" }, event.metadata)
    assert_equal "10.0.0.1", event.ip_address
    assert_equal "TestAgent", event.user_agent
  end

  test "record_click allows multiple clicks from same subscriber" do
    newsletter = newsletters(:sent_newsletter)
    subscriber = subscribers(:confirmed_subscriber)

    assert_difference "EmailEvent.count", 2 do
      EmailEvent.record_click(
        newsletter: newsletter,
        subscriber: subscriber,
        url: "https://example.com/link1"
      )
      EmailEvent.record_click(
        newsletter: newsletter,
        subscriber: subscriber,
        url: "https://example.com/link2"
      )
    end
  end

  test "record_click stores url in metadata" do
    event = EmailEvent.record_click(
      newsletter: newsletters(:draft_newsletter),
      subscriber: subscribers(:pending_subscriber),
      url: "https://test.com/path"
    )

    assert_equal "https://test.com/path", event.metadata["url"]
  end
end
