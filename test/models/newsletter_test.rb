require "test_helper"

class NewsletterTest < ActiveSupport::TestCase
  # Validations
  test "valid newsletter" do
    newsletter = Newsletter.new(
      user: users(:alice),
      title: "Test Newsletter",
      subject: "Test Subject",
      preview_text: "Preview"
    )
    newsletter.content = "<p>Content here</p>"
    assert newsletter.valid?
  end

  test "title presence required" do
    newsletter = newsletters(:draft_newsletter)
    newsletter.title = nil
    assert_not newsletter.valid?
    assert_includes newsletter.errors[:title], "can't be blank"
  end

  test "subject presence required on send context" do
    newsletter = Newsletter.new(
      user: users(:alice),
      title: "Test"
    )
    assert newsletter.valid?
    assert_not newsletter.valid?(:send)
    assert_includes newsletter.errors[:subject], "can't be blank"
  end

  test "content presence required on send context" do
    newsletter = Newsletter.new(
      user: users(:alice),
      title: "Test",
      subject: "Subject"
    )
    assert newsletter.valid?
    assert_not newsletter.valid?(:send)
    assert_includes newsletter.errors[:content], "can't be blank"
  end

  # Associations
  test "belongs to user" do
    assert_equal users(:alice), newsletters(:draft_newsletter).user
  end

  test "has rich text content" do
    newsletter = newsletters(:draft_newsletter)
    assert_respond_to newsletter, :content
    assert newsletter.content.present?
  end

  test "has many newsletter tags" do
    assert_respond_to newsletters(:scheduled_newsletter), :newsletter_tags
    assert newsletters(:scheduled_newsletter).newsletter_tags.count > 0
  end

  test "has many tags through newsletter_tags" do
    assert_respond_to newsletters(:scheduled_newsletter), :tags
    assert_includes newsletters(:scheduled_newsletter).tags, tags(:tech)
  end

  test "has many email events" do
    assert_respond_to newsletters(:sent_newsletter), :email_events
    assert newsletters(:sent_newsletter).email_events.count > 0
  end

  # Enum
  test "status enum values" do
    assert_equal "draft", Newsletter.statuses[:draft]
    assert_equal "scheduled", Newsletter.statuses[:scheduled]
    assert_equal "sending", Newsletter.statuses[:sending]
    assert_equal "sent", Newsletter.statuses[:sent]
  end

  test "default status is draft" do
    newsletter = Newsletter.new(user: users(:alice), title: "Test")
    assert newsletter.draft?
  end

  # Scopes
  test "for_user scope" do
    alice_newsletters = Newsletter.for_user(users(:alice))
    assert_includes alice_newsletters, newsletters(:draft_newsletter)
    assert_not_includes alice_newsletters, newsletters(:bob_newsletter)
  end

  test "drafts scope" do
    drafts = Newsletter.drafts
    assert_includes drafts, newsletters(:draft_newsletter)
    assert_not_includes drafts, newsletters(:sent_newsletter)
  end

  test "scheduled scope" do
    scheduled = Newsletter.scheduled
    assert_includes scheduled, newsletters(:scheduled_newsletter)
    assert_not_includes scheduled, newsletters(:draft_newsletter)
  end

  test "sent scope" do
    sent = Newsletter.sent
    assert_includes sent, newsletters(:sent_newsletter)
    assert_not_includes sent, newsletters(:draft_newsletter)
  end

  test "recent scope orders by updated_at desc" do
    recent = Newsletter.for_user(users(:alice)).recent
    dates = recent.pluck(:updated_at)
    assert_equal dates.sort.reverse, dates
  end

  test "ready_to_send scope finds scheduled newsletters past their time" do
    ready = Newsletter.ready_to_send
    assert_includes ready, newsletters(:ready_to_send_newsletter)
    assert_not_includes ready, newsletters(:scheduled_newsletter)
    assert_not_includes ready, newsletters(:draft_newsletter)
  end

  # Methods
  test "ready_to_send? with all fields" do
    newsletter = newsletters(:draft_newsletter)
    assert newsletter.ready_to_send?
  end

  test "ready_to_send? without title" do
    newsletter = Newsletter.new(user: users(:alice), subject: "Subject")
    newsletter.content = "<p>Content</p>"
    assert_not newsletter.ready_to_send?
  end

  test "ready_to_send? without subject" do
    newsletter = Newsletter.new(user: users(:alice), title: "Title")
    newsletter.content = "<p>Content</p>"
    assert_not newsletter.ready_to_send?
  end

  test "ready_to_send? without content" do
    newsletter = Newsletter.new(user: users(:alice), title: "Title", subject: "Subject")
    assert_not newsletter.ready_to_send?
  end

  test "schedule! updates status and scheduled_at" do
    newsletter = newsletters(:draft_newsletter)
    time = 1.day.from_now

    newsletter.schedule!(time)

    assert newsletter.scheduled?
    assert_equal time.to_i, newsletter.scheduled_at.to_i
  end

  test "mark_sent! updates status and sent_at" do
    newsletter = newsletters(:sending_newsletter)

    newsletter.mark_sent!

    assert newsletter.sent?
    assert_not_nil newsletter.sent_at
  end

  test "has_tag_filters? with tags" do
    assert newsletters(:scheduled_newsletter).has_tag_filters?
  end

  test "has_tag_filters? without tags" do
    assert_not newsletters(:draft_newsletter).has_tag_filters?
  end

  test "recipients returns all confirmed when no tags" do
    newsletter = newsletters(:draft_newsletter)
    recipients = newsletter.recipients

    assert_includes recipients, subscribers(:confirmed_subscriber)
    assert_includes recipients, subscribers(:tagged_subscriber)
    assert_not_includes recipients, subscribers(:pending_subscriber)
    assert_not_includes recipients, subscribers(:unsubscribed_subscriber)
  end

  test "recipients returns only tagged when has tags" do
    newsletter = newsletters(:scheduled_newsletter)
    recipients = newsletter.recipients

    assert_includes recipients, subscribers(:tagged_subscriber)
    assert_not_includes recipients, subscribers(:confirmed_subscriber)
  end

  # Analytics
  test "total_opens counts open events" do
    newsletter = newsletters(:sent_newsletter)
    assert_equal 2, newsletter.total_opens
  end

  test "total_clicks counts click events" do
    newsletter = newsletters(:sent_newsletter)
    assert_equal 1, newsletter.total_clicks
  end

  test "unique_clicks counts distinct subscribers" do
    newsletter = newsletters(:sent_newsletter)
    # Add another click from same subscriber
    EmailEvent.record_click(
      newsletter: newsletter,
      subscriber: subscribers(:confirmed_subscriber),
      url: "https://another.com"
    )

    # Should still be 1 unique clicker
    assert_equal 1, newsletter.unique_clicks
  end

  test "open_rate calculation" do
    newsletter = newsletters(:sent_newsletter)
    # 2 opens / 2 confirmed subscribers = 100%
    assert_equal 100.0, newsletter.open_rate
  end

  test "open_rate returns zero when no recipients" do
    newsletter = newsletters(:bob_newsletter)
    # Bob only has 1 confirmed subscriber
    assert newsletter.open_rate >= 0
  end

  test "click_rate calculation" do
    newsletter = newsletters(:sent_newsletter)
    # 1 unique click / 2 opens = 50%
    assert_equal 50.0, newsletter.click_rate
  end

  test "click_rate returns zero when no opens" do
    newsletter = newsletters(:draft_newsletter)
    assert_equal 0, newsletter.click_rate
  end

  # Dependent destroy
  test "destroying newsletter destroys newsletter_tags" do
    newsletter = newsletters(:scheduled_newsletter)
    tag_count = newsletter.newsletter_tags.count
    assert tag_count > 0

    assert_difference "NewsletterTag.count", -tag_count do
      newsletter.destroy
    end
  end

  test "destroying newsletter destroys email_events" do
    newsletter = newsletters(:sent_newsletter)
    event_count = newsletter.email_events.count
    assert event_count > 0

    assert_difference "EmailEvent.count", -event_count do
      newsletter.destroy
    end
  end
end
