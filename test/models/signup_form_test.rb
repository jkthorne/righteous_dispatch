require "test_helper"

class SignupFormTest < ActiveSupport::TestCase
  # Validations
  test "valid signup form" do
    form = SignupForm.new(
      user: users(:alice),
      title: "New Form",
      headline: "Join Us",
      description: "Get updates"
    )
    assert form.valid?
  end

  test "title presence required" do
    form = signup_forms(:active_form)
    form.title = nil
    assert_not form.valid?
    assert_includes form.errors[:title], "can't be blank"
  end

  test "public_id presence required" do
    form = signup_forms(:active_form)
    form.public_id = nil
    assert_not form.valid?
    assert_includes form.errors[:public_id], "can't be blank"
  end

  test "public_id uniqueness" do
    form = SignupForm.new(
      user: users(:bob),
      title: "Duplicate ID Form",
      public_id: signup_forms(:active_form).public_id
    )
    assert_not form.valid?
    assert_includes form.errors[:public_id], "has already been taken"
  end

  # Associations
  test "belongs to user" do
    assert_equal users(:alice), signup_forms(:active_form).user
  end

  test "has many signup form tags" do
    assert_respond_to signup_forms(:active_form), :signup_form_tags
    assert signup_forms(:active_form).signup_form_tags.count > 0
  end

  test "has many tags through signup_form_tags" do
    assert_respond_to signup_forms(:active_form), :tags
    assert_includes signup_forms(:active_form).tags, tags(:tech)
    assert_includes signup_forms(:active_form).tags, tags(:sports)
  end

  # Callbacks
  test "public_id generated on create" do
    form = SignupForm.create!(
      user: users(:alice),
      title: "New Form"
    )
    assert_not_nil form.public_id
    assert_equal 10, form.public_id.length
  end

  test "public_id not overwritten if present" do
    custom_id = "customid123"
    form = SignupForm.create!(
      user: users(:alice),
      title: "Custom ID Form",
      public_id: custom_id
    )
    assert_equal custom_id, form.public_id
  end

  # Scopes
  test "active scope" do
    active = SignupForm.active
    assert_includes active, signup_forms(:active_form)
    assert_not_includes active, signup_forms(:inactive_form)
  end

  # Methods
  test "to_param returns public_id" do
    form = signup_forms(:active_form)
    assert_equal form.public_id, form.to_param
  end

  # Default values
  test "default values set" do
    form = SignupForm.new(user: users(:alice), title: "Test")
    form.save!

    assert_equal true, form.active
    assert_equal "Subscribe", form.button_text
    assert_equal "Subscribe to our newsletter", form.headline
    assert_equal "Thanks for subscribing!", form.success_message
  end

  # Dependent destroy
  test "destroying signup form destroys signup_form_tags" do
    form = signup_forms(:active_form)
    tag_count = form.signup_form_tags.count
    assert tag_count > 0

    assert_difference "SignupFormTag.count", -tag_count do
      form.destroy
    end
  end
end
