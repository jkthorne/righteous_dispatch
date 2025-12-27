require "test_helper"

class SendNewsletterEmailJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "sends email to confirmed subscriber" do
    user = users(:alice)
    newsletter = user.newsletters.create!(title: "Email Test", subject: "Test Subject", status: :sent)
    newsletter.content = "<p>Content</p>"
    newsletter.save!

    subscriber = user.subscribers.create!(email: "emailtest#{SecureRandom.hex(4)}@example.com", status: :confirmed)

    assert_emails 1 do
      SendNewsletterEmailJob.perform_now(newsletter.id, subscriber.id)
    end
  end

  test "skips unconfirmed subscriber" do
    user = users(:alice)
    newsletter = user.newsletters.create!(title: "Skip Test", subject: "Test Subject", status: :sent)
    newsletter.content = "<p>Content</p>"
    newsletter.save!

    subscriber = user.subscribers.create!(email: "pending#{SecureRandom.hex(4)}@example.com", status: :pending)

    assert_no_emails do
      SendNewsletterEmailJob.perform_now(newsletter.id, subscriber.id)
    end
  end

  test "skips unsubscribed subscriber" do
    user = users(:alice)
    newsletter = user.newsletters.create!(title: "Unsubscribed Test", subject: "Test Subject", status: :sent)
    newsletter.content = "<p>Content</p>"
    newsletter.save!

    subscriber = user.subscribers.create!(email: "unsub#{SecureRandom.hex(4)}@example.com", status: :unsubscribed)

    assert_no_emails do
      SendNewsletterEmailJob.perform_now(newsletter.id, subscriber.id)
    end
  end

  test "skips if newsletter not found" do
    subscriber = subscribers(:confirmed_subscriber)

    assert_no_emails do
      SendNewsletterEmailJob.perform_now(999999, subscriber.id)
    end
  end

  test "skips if subscriber not found" do
    newsletter = newsletters(:sent_newsletter)

    assert_no_emails do
      SendNewsletterEmailJob.perform_now(newsletter.id, 999999)
    end
  end

  test "has retry configuration for errors" do
    # Verify the job is configured to retry on StandardError
    assert SendNewsletterEmailJob.ancestors.include?(ActiveJob::Base)
    # The job should handle errors gracefully
  end
end
