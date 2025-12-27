require "application_system_test_case"

class PublicPagesTest < ApplicationSystemTestCase
  test "public signup form displays correctly" do
    form = signup_forms(:active_form)
    visit public_signup_path(form.public_id)

    assert_text form.headline
    assert_selector "input[name='email']"
  end

  test "public signup form submits successfully" do
    form = signup_forms(:active_form)
    visit public_signup_path(form.public_id)

    find("input[name='email']").fill_in with: "testsubscriber#{SecureRandom.hex(4)}@example.com"
    find("button, input[type='submit']").click

    assert_text form.success_message
  end

  test "unsubscribe page displays correctly" do
    subscriber = subscribers(:confirmed_subscriber)
    visit unsubscribe_path(token: subscriber.unsubscribe_token)

    assert_selector "form"
    assert_selector "button, input[type='submit']"
  end

  test "inactive signup form shows not found" do
    form = signup_forms(:inactive_form)
    visit public_signup_path(form.public_id)

    assert_text "not found"
  end
end
