require "test_helper"

class NewsletterSendingFlowTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:alice))
  end

  test "complete newsletter creation and sending flow" do
    # Create newsletter
    assert_difference "Newsletter.count", 1 do
      post newsletters_path, params: {
        newsletter: {
          title: "Integration Test Newsletter",
          subject: "Test Subject",
          preview_text: "Preview text",
          content: "<p>Newsletter content</p>"
        }
      }
    end

    newsletter = Newsletter.last
    assert_redirected_to edit_newsletter_path(newsletter)
    assert newsletter.draft?

    # Edit and finalize
    patch newsletter_path(newsletter), params: {
      newsletter: { title: "Updated Title" }
    }
    assert_redirected_to edit_newsletter_path(newsletter)

    # Preview
    get preview_newsletter_path(newsletter)
    assert_response :success

    # Confirm send page
    get confirm_send_newsletter_path(newsletter)
    assert_response :success

    # Send newsletter
    assert_enqueued_with(job: SendNewsletterJob) do
      post send_newsletter_newsletter_path(newsletter)
    end

    assert_redirected_to newsletters_path
    assert newsletter.reload.sending?
  end

  test "newsletter scheduling flow" do
    newsletter = newsletters(:draft_newsletter)
    future_date = 1.day.from_now.to_date.to_s
    future_time = "14:00"

    post schedule_newsletter_path(newsletter), params: {
      scheduled_date: future_date,
      scheduled_time: future_time
    }

    assert_redirected_to newsletters_path
    assert newsletter.reload.scheduled?
    assert_not_nil newsletter.scheduled_at
  end

  test "newsletter with tag targeting flow" do
    newsletter = newsletters(:draft_newsletter)
    tag = tags(:tech)

    # Add tag targeting
    patch update_tags_newsletter_path(newsletter), params: {
      tag_ids: [tag.id]
    }

    assert_redirected_to confirm_send_newsletter_path(newsletter)
    assert_includes newsletter.reload.tags, tag
  end

  test "draft newsletter flow shows in index" do
    get newsletters_path
    assert_response :success
    assert_select "a[href=?]", edit_newsletter_path(newsletters(:draft_newsletter))
  end

  test "sent newsletter cannot be sent again" do
    newsletter = newsletters(:sent_newsletter)

    post send_newsletter_newsletter_path(newsletter)

    assert_redirected_to newsletters_path
    follow_redirect!
    assert_match /already been sent/, flash[:alert]
  end
end
