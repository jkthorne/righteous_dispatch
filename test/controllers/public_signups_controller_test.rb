require "test_helper"

class PublicSignupsControllerTest < ActionDispatch::IntegrationTest
  test "show renders active form" do
    form = signup_forms(:active_form)
    get public_signup_path(form.public_id)
    assert_response :success
  end

  test "show returns not found for inactive form" do
    form = signup_forms(:inactive_form)
    get public_signup_path(form.public_id)
    assert_response :not_found
  end

  test "show returns not found for invalid id" do
    get public_signup_path("invalid_id")
    assert_response :not_found
  end

  test "create with valid email" do
    form = signup_forms(:active_form)

    assert_difference "Subscriber.count", 1 do
      post public_signup_path(form.public_id), params: {
        email: "newsubscriber@example.com",
        name: "New Subscriber"
      }
    end

    assert_redirected_to public_signup_path(form.public_id)
    assert_match form.success_message, flash[:notice]

    subscriber = Subscriber.last
    assert_equal "newsubscriber@example.com", subscriber.email
    assert_equal "New Subscriber", subscriber.first_name
    assert subscriber.confirmed?
  end

  test "create with invalid email" do
    form = signup_forms(:active_form)

    assert_no_difference "Subscriber.count" do
      post public_signup_path(form.public_id), params: {
        email: "invalid-email"
      }
    end

    assert_redirected_to public_signup_path(form.public_id)
    assert_match /valid email/, flash[:alert]
  end

  test "create applies form tags to subscriber" do
    form = signup_forms(:active_form)

    post public_signup_path(form.public_id), params: {
      email: "tagged@example.com"
    }

    subscriber = Subscriber.find_by(email: "tagged@example.com")
    form.tags.each do |tag|
      assert_includes subscriber.tags, tag
    end
  end

  test "create with existing subscriber updates" do
    form = signup_forms(:active_form)
    existing = subscribers(:confirmed_subscriber)
    original_count = Subscriber.count

    post public_signup_path(form.public_id), params: {
      email: existing.email
    }

    assert_equal original_count, Subscriber.count
    assert_redirected_to public_signup_path(form.public_id)
  end

  test "create sends welcome email when enabled" do
    form = signup_forms(:active_form)
    # Alice has welcome_email_enabled: true

    assert_enqueued_emails 1 do
      post public_signup_path(form.public_id), params: {
        email: "welcometest@example.com"
      }
    end
  end

  test "create does not send welcome email when disabled" do
    form = signup_forms(:bob_form)
    # Bob has welcome_email_enabled: false

    assert_no_enqueued_emails do
      post public_signup_path(form.public_id), params: {
        email: "nowelcome@example.com"
      }
    end
  end

  test "create responds to json" do
    form = signup_forms(:active_form)

    post public_signup_path(form.public_id),
         params: { email: "jsontest@example.com" },
         as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert json["success"]
    assert_equal form.success_message, json["message"]
  end

  test "create returns json error for invalid email" do
    form = signup_forms(:active_form)

    post public_signup_path(form.public_id),
         params: { email: "invalid" },
         as: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_not json["success"]
    assert json["error"].present?
  end
end
