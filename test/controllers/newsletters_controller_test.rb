require "test_helper"

class NewslettersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:alice)
  end

  # Authentication tests
  test "index requires authentication" do
    delete session_path # Sign out
    get newsletters_path
    assert_redirected_to new_session_path
  end

  test "show requires authentication" do
    delete session_path
    get newsletter_path(newsletters(:draft_newsletter))
    assert_redirected_to new_session_path
  end

  # Index
  test "index returns user newsletters" do
    get newsletters_path
    assert_response :success
    assert_select "h1", /Newsletter/i
  end

  # Show
  test "show displays newsletter" do
    get newsletter_path(newsletters(:draft_newsletter))
    assert_response :success
  end

  test "show returns not found for other users newsletter" do
    get newsletter_path(newsletters(:bob_newsletter))
    assert_response :not_found
  end

  # New
  test "new builds newsletter" do
    get new_newsletter_path
    assert_response :success
    assert_select "form"
  end

  # Create
  test "create with valid params" do
    assert_difference "Newsletter.count", 1 do
      post newsletters_path, params: {
        newsletter: {
          title: "New Newsletter",
          subject: "New Subject",
          preview_text: "Preview",
          content: "<p>Content</p>"
        }
      }
    end
    assert_redirected_to edit_newsletter_path(Newsletter.last)
  end

  test "create with invalid params" do
    assert_no_difference "Newsletter.count" do
      post newsletters_path, params: {
        newsletter: { title: "" }
      }
    end
    assert_response :unprocessable_entity
  end

  # Edit
  test "edit displays form" do
    get edit_newsletter_path(newsletters(:draft_newsletter))
    assert_response :success
    assert_select "form"
  end

  test "edit returns not found for other users newsletter" do
    get edit_newsletter_path(newsletters(:bob_newsletter))
    assert_response :not_found
  end

  # Update
  test "update with valid params" do
    patch newsletter_path(newsletters(:draft_newsletter)), params: {
      newsletter: { title: "Updated Title" }
    }
    assert_redirected_to edit_newsletter_path(newsletters(:draft_newsletter))
    assert_equal "Updated Title", newsletters(:draft_newsletter).reload.title
  end

  test "update with invalid params" do
    patch newsletter_path(newsletters(:draft_newsletter)), params: {
      newsletter: { title: "" }
    }
    assert_response :unprocessable_entity
  end

  test "update returns not found for other users newsletter" do
    patch newsletter_path(newsletters(:bob_newsletter)), params: {
      newsletter: { title: "Hacked" }
    }
    assert_response :not_found
  end

  # Destroy
  test "destroy removes newsletter" do
    newsletter = newsletters(:draft_newsletter)
    assert_difference "Newsletter.count", -1 do
      delete newsletter_path(newsletter)
    end
    assert_redirected_to newsletters_path
  end

  test "destroy returns not found for other users newsletter" do
    delete newsletter_path(newsletters(:bob_newsletter))
    assert_response :not_found
  end

  # Preview
  test "preview with confirmed subscriber" do
    get preview_newsletter_path(newsletters(:draft_newsletter))
    assert_response :success
  end

  # Confirm Send
  test "confirm_send shows recipient count" do
    get confirm_send_newsletter_path(newsletters(:draft_newsletter))
    assert_response :success
  end

  test "confirm_send redirects when not ready" do
    newsletter = newsletters(:draft_newsletter)
    newsletter.update!(subject: nil)

    get confirm_send_newsletter_path(newsletter)
    assert_redirected_to edit_newsletter_path(newsletter)
    assert_match /missing required fields/, flash[:alert]
  end

  test "confirm_send redirects when no confirmed subscribers" do
    # Remove all confirmed subscribers
    users(:alice).subscribers.confirmed.each { |s| s.update!(status: :pending) }

    get confirm_send_newsletter_path(newsletters(:draft_newsletter))
    assert_redirected_to edit_newsletter_path(newsletters(:draft_newsletter))
    assert_match /no confirmed subscribers/, flash[:alert]
  end

  # Update Tags
  test "update_tags assigns tags" do
    newsletter = newsletters(:draft_newsletter)
    patch update_tags_newsletter_path(newsletter), params: {
      tag_ids: [tags(:tech).id, tags(:sports).id]
    }
    assert_redirected_to confirm_send_newsletter_path(newsletter)
    assert_includes newsletter.reload.tags, tags(:tech)
    assert_includes newsletter.reload.tags, tags(:sports)
  end

  # Send Newsletter
  test "send_newsletter queues job" do
    newsletter = newsletters(:draft_newsletter)

    assert_enqueued_with(job: SendNewsletterJob) do
      post send_newsletter_newsletter_path(newsletter)
    end

    assert_redirected_to newsletters_path
    assert newsletter.reload.sending?
  end

  test "send_newsletter rejects already sent" do
    post send_newsletter_newsletter_path(newsletters(:sent_newsletter))
    assert_redirected_to newsletters_path
    assert_match /already been sent/, flash[:alert]
  end

  test "send_newsletter rejects unready" do
    newsletter = newsletters(:draft_newsletter)
    newsletter.update!(subject: nil)

    post send_newsletter_newsletter_path(newsletter)
    assert_redirected_to edit_newsletter_path(newsletter)
    assert_match /missing required fields/, flash[:alert]
  end

  # Schedule
  test "schedule with future time" do
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

  test "schedule rejects past time" do
    newsletter = newsletters(:draft_newsletter)
    past_date = 1.day.ago.to_date.to_s
    past_time = "14:00"

    post schedule_newsletter_path(newsletter), params: {
      scheduled_date: past_date,
      scheduled_time: past_time
    }

    assert_redirected_to confirm_send_newsletter_path(newsletter)
    assert_match /must be in the future/, flash[:alert]
  end

  test "schedule rejects invalid time" do
    newsletter = newsletters(:draft_newsletter)

    post schedule_newsletter_path(newsletter), params: {
      scheduled_date: "",
      scheduled_time: ""
    }

    assert_redirected_to confirm_send_newsletter_path(newsletter)
    assert_match /valid date and time/, flash[:alert]
  end

  test "schedule rejects already sent" do
    post schedule_newsletter_path(newsletters(:sent_newsletter)), params: {
      scheduled_date: 1.day.from_now.to_date.to_s,
      scheduled_time: "14:00"
    }

    assert_redirected_to newsletters_path
    assert_match /already been sent/, flash[:alert]
  end
end
