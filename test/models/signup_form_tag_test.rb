require "test_helper"

class SignupFormTagTest < ActiveSupport::TestCase
  test "valid signup form tag" do
    signup_form_tag = SignupFormTag.new(
      signup_form: signup_forms(:inactive_form),
      tag: tags(:tech)
    )
    assert signup_form_tag.valid?
  end

  test "belongs to signup form" do
    assert_equal signup_forms(:active_form), signup_form_tags(:active_form_tech).signup_form
  end

  test "belongs to tag" do
    assert_equal tags(:tech), signup_form_tags(:active_form_tech).tag
  end

  test "same signup form can have multiple tags" do
    form = signup_forms(:active_form)
    new_tag = SignupFormTag.new(
      signup_form: form,
      tag: tags(:news)
    )
    assert new_tag.valid?
  end

  test "same tag can be on multiple signup forms" do
    tag = tags(:tech)
    new_form_tag = SignupFormTag.new(
      signup_form: signup_forms(:inactive_form),
      tag: tag
    )
    assert new_form_tag.valid?
  end
end
