require "test_helper"

class ProcessScheduledNewslettersJobTest < ActiveJob::TestCase
  setup do
    # Reset any ready_to_send newsletters from fixtures to avoid interference
    Newsletter.scheduled.where("scheduled_at <= ?", Time.current).update_all(status: :draft)
  end

  test "finds and processes ready newsletters" do
    user = users(:alice)

    # Create a scheduled newsletter that's ready to send
    newsletter = user.newsletters.create!(
      title: "Scheduled Test",
      subject: "Test",
      status: :scheduled,
      scheduled_at: 1.hour.ago
    )
    newsletter.content = "<p>Content</p>"
    newsletter.save!

    assert_enqueued_jobs 1, only: SendNewsletterJob do
      ProcessScheduledNewslettersJob.perform_now
    end

    assert newsletter.reload.sending?
  end

  test "ignores newsletters scheduled for the future" do
    user = users(:alice)

    # Create a scheduled newsletter that's not ready yet
    newsletter = user.newsletters.create!(
      title: "Future Test",
      subject: "Test",
      status: :scheduled,
      scheduled_at: 1.hour.from_now
    )
    newsletter.content = "<p>Content</p>"
    newsletter.save!

    assert_no_enqueued_jobs only: SendNewsletterJob do
      ProcessScheduledNewslettersJob.perform_now
    end

    assert newsletter.reload.scheduled?
  end

  test "ignores draft newsletters" do
    newsletter = newsletters(:draft_newsletter)

    assert_no_enqueued_jobs only: SendNewsletterJob do
      ProcessScheduledNewslettersJob.perform_now
    end

    assert newsletter.reload.draft?
  end

  test "ignores sent newsletters" do
    newsletter = newsletters(:sent_newsletter)

    assert_no_enqueued_jobs only: SendNewsletterJob do
      ProcessScheduledNewslettersJob.perform_now
    end

    assert newsletter.reload.sent?
  end

  test "processes multiple ready newsletters" do
    user = users(:alice)

    # Create multiple scheduled newsletters ready to send
    newsletters = 2.times.map do |i|
      newsletter = user.newsletters.create!(
        title: "Batch Test #{i}",
        subject: "Test",
        status: :scheduled,
        scheduled_at: i.minutes.ago
      )
      newsletter.content = "<p>Content</p>"
      newsletter.save!
      newsletter
    end

    assert_enqueued_jobs 2, only: SendNewsletterJob do
      ProcessScheduledNewslettersJob.perform_now
    end

    newsletters.each { |n| assert n.reload.sending? }
  end
end
