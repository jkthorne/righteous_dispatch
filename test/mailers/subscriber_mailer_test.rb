require "test_helper"

class SubscriberMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers

  test "welcome email sends when enabled with subject" do
    subscriber = subscribers(:confirmed_subscriber)
    # Alice has welcome_email_enabled: true and welcome_email_subject set
    email = SubscriberMailer.welcome(subscriber: subscriber)

    assert_equal [subscriber.email], email.to
    assert_equal subscriber.user.welcome_email_subject, email.subject
  end

  test "welcome email includes user name in from" do
    subscriber = subscribers(:confirmed_subscriber)
    email = SubscriberMailer.welcome(subscriber: subscriber)

    from_header = email[:from].to_s
    assert_match subscriber.user.name, from_header
  end

  test "welcome email includes unsubscribe link" do
    subscriber = subscribers(:confirmed_subscriber)
    email = SubscriberMailer.welcome(subscriber: subscriber)

    # Check for unsubscribe URL pattern (token may be split by quoted-printable encoding)
    assert_match %r{/unsubscribe/}, email.body.encoded
  end

  test "welcome email includes welcome content" do
    subscriber = subscribers(:confirmed_subscriber)
    email = SubscriberMailer.welcome(subscriber: subscriber)

    assert_match subscriber.user.welcome_email_content, email.body.encoded
  end

  test "welcome email not sent when disabled" do
    subscriber = subscribers(:bob_subscriber)
    # Bob has welcome_email_enabled: false
    email = SubscriberMailer.welcome(subscriber: subscriber)

    # When welcome email is disabled, the mailer returns nil (no delivery)
    assert_nil email.to
  end

  test "welcome email not sent when subject is blank" do
    user = users(:alice)
    user.update!(welcome_email_subject: "")
    subscriber = user.subscribers.create!(email: "blank_subject#{SecureRandom.hex(4)}@example.com", status: :confirmed)

    email = SubscriberMailer.welcome(subscriber: subscriber)

    assert_nil email.to
  end
end
