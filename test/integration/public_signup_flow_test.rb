require "test_helper"

class PublicSignupFlowTest < ActionDispatch::IntegrationTest
  test "complete public signup flow" do
    form = signup_forms(:active_form)

    # View signup form
    get public_signup_path(form.public_id)
    assert_response :success

    # Submit signup
    assert_difference "Subscriber.count", 1 do
      post public_signup_path(form.public_id), params: {
        email: "publicsignup#{SecureRandom.hex(4)}@example.com",
        first_name: "Test",
        last_name: "User"
      }
    end

    # Controller redirects back to form with success notice
    assert_redirected_to public_signup_path(form.public_id)
    subscriber = Subscriber.last
    assert_equal "confirmed", subscriber.status
  end

  test "signup form applies configured tags" do
    form = signup_forms(:active_form)
    form.tags << tags(:tech) unless form.tags.include?(tags(:tech))

    email = "tagged#{SecureRandom.hex(4)}@example.com"
    post public_signup_path(form.public_id), params: {
      email: email,
      first_name: "Tagged"
    }

    subscriber = Subscriber.find_by(email: email)
    assert_includes subscriber.tags, tags(:tech)
  end

  test "inactive signup form returns not found" do
    form = signup_forms(:inactive_form)

    get public_signup_path(form.public_id)
    assert_response :not_found
  end

  test "invalid public_id returns not found" do
    get public_signup_path("nonexistent123")
    assert_response :not_found
  end

  test "duplicate email resubscription reactivates subscriber" do
    form = signup_forms(:active_form)
    existing = subscribers(:confirmed_subscriber)

    # Should not create new subscriber
    assert_no_difference "Subscriber.count" do
      post public_signup_path(form.public_id), params: {
        email: existing.email,
        first_name: "Resubscribed"
      }
    end
  end

  test "unsubscribe flow" do
    subscriber = subscribers(:confirmed_subscriber)

    # View unsubscribe page
    get unsubscribe_path(token: subscriber.unsubscribe_token)
    assert_response :success

    # Confirm unsubscribe
    post unsubscribe_path(token: subscriber.unsubscribe_token)

    assert subscriber.reload.unsubscribed?
  end

  test "unsubscribe with invalid token redirects to root" do
    # Invalid tokens redirect to root, not 404
    get unsubscribe_path(token: "invalid_token")
    assert_redirected_to root_path
  end

  test "welcome email sent when enabled" do
    form = signup_forms(:active_form)
    # Alice (form owner) has welcome_email_enabled: true

    # Uses deliver_later
    assert_enqueued_emails 1 do
      post public_signup_path(form.public_id), params: {
        email: "welcome#{SecureRandom.hex(4)}@example.com"
      }
    end
  end
end
