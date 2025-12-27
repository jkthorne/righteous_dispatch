require "test_helper"

class UserTest < ActiveSupport::TestCase
  # Validations
  test "valid user" do
    user = User.new(
      name: "Test User",
      email: "test@example.com",
      password: "password123"
    )
    assert user.valid?
  end

  test "email presence required" do
    user = users(:alice)
    user.email = nil
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "email format validation" do
    user = users(:alice)
    user.email = "invalid-email"
    assert_not user.valid?
    assert_includes user.errors[:email], "is invalid"
  end

  test "email uniqueness" do
    user = User.new(
      name: "Duplicate",
      email: users(:alice).email,
      password: "password123"
    )
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "email uniqueness case insensitive" do
    user = User.new(
      name: "Duplicate",
      email: users(:alice).email.upcase,
      password: "password123"
    )
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "name presence required" do
    user = users(:alice)
    user.name = nil
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "password minimum length" do
    user = User.new(
      name: "Test",
      email: "new@example.com",
      password: "short"
    )
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 8 characters)"
  end

  test "password validation skipped when blank on update" do
    user = users(:alice)
    user.name = "Updated Name"
    assert user.valid?
  end

  # Normalizations
  test "email normalized to lowercase" do
    user = User.new(
      name: "Test",
      email: "  TEST@EXAMPLE.COM  ",
      password: "password123"
    )
    user.validate
    assert_equal "test@example.com", user.email
  end

  # Callbacks
  test "confirmation token set on create" do
    user = User.create!(
      name: "New User",
      email: "new@example.com",
      password: "password123"
    )
    assert_not_nil user.confirmation_token
    assert_not_nil user.confirmation_sent_at
  end

  test "remember token set on create" do
    user = User.create!(
      name: "New User",
      email: "new2@example.com",
      password: "password123"
    )
    assert_not_nil user.remember_token
    assert_not_nil user.remember_created_at
  end

  # Associations
  test "has many newsletters" do
    assert_respond_to users(:alice), :newsletters
    assert_includes users(:alice).newsletters, newsletters(:draft_newsletter)
  end

  test "has many subscribers" do
    assert_respond_to users(:alice), :subscribers
    assert_includes users(:alice).subscribers, subscribers(:confirmed_subscriber)
  end

  test "has many tags" do
    assert_respond_to users(:alice), :tags
    assert_includes users(:alice).tags, tags(:tech)
  end

  test "has many signup forms" do
    assert_respond_to users(:alice), :signup_forms
    assert_includes users(:alice).signup_forms, signup_forms(:active_form)
  end

  test "dependent destroy newsletters" do
    user = users(:alice)
    newsletter_count = user.newsletters.count
    assert newsletter_count > 0

    assert_difference "Newsletter.count", -newsletter_count do
      user.destroy
    end
  end

  test "dependent destroy subscribers" do
    user = users(:alice)
    subscriber_count = user.subscribers.count
    assert subscriber_count > 0

    assert_difference "Subscriber.count", -subscriber_count do
      user.destroy
    end
  end

  test "dependent destroy tags" do
    user = users(:alice)
    tag_count = user.tags.count
    assert tag_count > 0

    assert_difference "Tag.count", -tag_count do
      user.destroy
    end
  end

  test "dependent destroy signup forms" do
    user = users(:alice)
    form_count = user.signup_forms.count
    assert form_count > 0

    assert_difference "SignupForm.count", -form_count do
      user.destroy
    end
  end

  # Authentication methods
  test "has secure password" do
    user = users(:alice)
    assert user.authenticate("password123")
    assert_not user.authenticate("wrong_password")
  end

  test "confirmed? returns true when confirmed_at present" do
    user = users(:alice)
    assert user.confirmed?
  end

  test "confirmed? returns false when confirmed_at nil" do
    user = users(:bob)
    assert_not user.confirmed?
  end

  test "confirm! updates confirmed_at and clears token" do
    user = users(:bob)
    assert_not user.confirmed?
    assert_not_nil user.confirmation_token

    user.confirm!

    assert user.confirmed?
    assert_nil user.confirmation_token
  end

  test "generate_confirmation_token! updates token and sent_at" do
    user = users(:alice)
    old_token = user.confirmation_token

    user.generate_confirmation_token!

    assert_not_equal old_token, user.confirmation_token
    assert_not_nil user.confirmation_sent_at
  end

  test "generate_password_reset_token! sets token and sent_at" do
    user = users(:alice)
    assert_nil user.password_reset_token

    user.generate_password_reset_token!

    assert_not_nil user.password_reset_token
    assert_not_nil user.password_reset_sent_at
  end

  test "password_reset_token_valid? within two hours" do
    user = users(:charlie)
    assert user.password_reset_token_valid?
  end

  test "password_reset_token_valid? after two hours" do
    user = users(:charlie)
    user.update!(password_reset_sent_at: 3.hours.ago)
    assert_not user.password_reset_token_valid?
  end

  test "password_reset_token_valid? false when no sent_at" do
    user = users(:alice)
    assert_nil user.password_reset_sent_at
    assert_not user.password_reset_token_valid?
  end

  test "clear_password_reset_token! clears token and sent_at" do
    user = users(:charlie)
    assert_not_nil user.password_reset_token

    user.clear_password_reset_token!

    assert_nil user.password_reset_token
    assert_nil user.password_reset_sent_at
  end

  test "regenerate_remember_token! updates token and created_at" do
    user = users(:alice)
    old_token = user.remember_token

    user.regenerate_remember_token!

    assert_not_equal old_token, user.remember_token
    assert_not_nil user.remember_created_at
  end
end
