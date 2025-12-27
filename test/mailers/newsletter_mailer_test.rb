require "test_helper"

class NewsletterMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers

  test "newsletter email has correct recipient" do
    newsletter = newsletters(:sent_newsletter)
    subscriber = subscribers(:confirmed_subscriber)
    email = NewsletterMailer.newsletter(newsletter: newsletter, subscriber: subscriber)

    assert_equal [subscriber.email], email.to
  end

  test "newsletter email has correct subject" do
    newsletter = newsletters(:sent_newsletter)
    subscriber = subscribers(:confirmed_subscriber)
    email = NewsletterMailer.newsletter(newsletter: newsletter, subscriber: subscriber)

    assert_equal newsletter.subject, email.subject
  end

  test "newsletter email from includes user name" do
    newsletter = newsletters(:sent_newsletter)
    subscriber = subscribers(:confirmed_subscriber)
    email = NewsletterMailer.newsletter(newsletter: newsletter, subscriber: subscriber)

    # The from field includes the user's name before the email
    from_header = email[:from].to_s
    assert_match newsletter.user.name, from_header
  end

  test "newsletter email includes unsubscribe link" do
    newsletter = newsletters(:sent_newsletter)
    subscriber = subscribers(:confirmed_subscriber)
    email = NewsletterMailer.newsletter(newsletter: newsletter, subscriber: subscriber)

    # Check for unsubscribe token in the body
    assert_match subscriber.unsubscribe_token, email.body.encoded
  end

  test "newsletter email includes tracking pixel" do
    newsletter = newsletters(:sent_newsletter)
    subscriber = subscribers(:confirmed_subscriber)
    email = NewsletterMailer.newsletter(newsletter: newsletter, subscriber: subscriber)

    # Check for tracking pixel URL pattern
    assert_match %r{/t/o/}, email.body.encoded
  end

  test "newsletter email includes view in browser link" do
    newsletter = newsletters(:sent_newsletter)
    subscriber = subscribers(:confirmed_subscriber)
    email = NewsletterMailer.newsletter(newsletter: newsletter, subscriber: subscriber)

    # Check for view in browser link with newsletter id
    assert_match %r{/newsletters/#{newsletter.id}/view/}, email.body.encoded
  end
end
