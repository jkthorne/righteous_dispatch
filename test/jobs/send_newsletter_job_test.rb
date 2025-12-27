require "test_helper"

class SendNewsletterJobTest < ActiveJob::TestCase
  test "queues individual email jobs for each recipient" do
    user = users(:alice)
    # Clear existing subscribers to have controlled test
    user.subscribers.destroy_all

    newsletter = user.newsletters.create!(title: "Job Test", subject: "Test", status: :sending)
    newsletter.content = "<p>Content</p>"
    newsletter.save!

    # Create some confirmed subscribers
    user.subscribers.create!(email: "job1@example.com", status: :confirmed)
    user.subscribers.create!(email: "job2@example.com", status: :confirmed)

    assert_enqueued_jobs 2, only: SendNewsletterEmailJob do
      SendNewsletterJob.perform_now(newsletter.id)
    end
  end

  test "marks newsletter as sent after queuing" do
    user = users(:alice)
    newsletter = user.newsletters.create!(title: "Sent Test", subject: "Test", status: :sending)
    newsletter.content = "<p>Content</p>"
    newsletter.save!

    SendNewsletterJob.perform_now(newsletter.id)

    assert newsletter.reload.sent?
  end

  test "skips if newsletter not found" do
    assert_nothing_raised do
      SendNewsletterJob.perform_now(999999)
    end
  end

  test "skips if newsletter not in sending status" do
    newsletter = newsletters(:draft_newsletter)

    assert_no_enqueued_jobs only: SendNewsletterEmailJob do
      SendNewsletterJob.perform_now(newsletter.id)
    end

    assert newsletter.reload.draft?
  end

  test "respects tag filters" do
    user = users(:alice)
    # Clear existing subscribers
    user.subscribers.destroy_all

    newsletter = user.newsletters.create!(title: "Tag Filter Test", subject: "Test", status: :sending)
    newsletter.content = "<p>Content</p>"
    newsletter.save!

    tag = tags(:tech)
    newsletter.tags << tag

    # Create subscribers with and without the tag
    tagged_subscriber = user.subscribers.create!(email: "tagged@example.com", status: :confirmed)
    tagged_subscriber.tags << tag
    user.subscribers.create!(email: "untagged@example.com", status: :confirmed)

    assert_enqueued_jobs 1, only: SendNewsletterEmailJob do
      SendNewsletterJob.perform_now(newsletter.id)
    end
  end

  test "only queues for confirmed subscribers" do
    user = users(:alice)
    # Remove existing subscribers to have a clean slate
    user.subscribers.destroy_all

    newsletter = user.newsletters.create!(title: "Confirmed Only Test", subject: "Test", status: :sending)
    newsletter.content = "<p>Content</p>"
    newsletter.save!

    user.subscribers.create!(email: "confirmed@example.com", status: :confirmed)
    user.subscribers.create!(email: "pending@example.com", status: :pending)
    user.subscribers.create!(email: "unsubscribed@example.com", status: :unsubscribed)

    assert_enqueued_jobs 1, only: SendNewsletterEmailJob do
      SendNewsletterJob.perform_now(newsletter.id)
    end
  end
end
