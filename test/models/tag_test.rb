require "test_helper"

class TagTest < ActiveSupport::TestCase
  # Validations
  test "valid tag" do
    tag = Tag.new(
      user: users(:alice),
      name: "New Tag",
      color: "#ff0000"
    )
    assert tag.valid?
  end

  test "name presence required" do
    tag = tags(:tech)
    tag.name = nil
    assert_not tag.valid?
    assert_includes tag.errors[:name], "can't be blank"
  end

  test "name uniqueness scoped to user" do
    tag = Tag.new(
      user: users(:alice),
      name: tags(:tech).name
    )
    assert_not tag.valid?
    assert_includes tag.errors[:name], "has already been taken"
  end

  test "name uniqueness case insensitive" do
    tag = Tag.new(
      user: users(:alice),
      name: tags(:tech).name.upcase
    )
    assert_not tag.valid?
    assert_includes tag.errors[:name], "has already been taken"
  end

  test "same name allowed for different users" do
    tag = Tag.new(
      user: users(:bob),
      name: tags(:tech).name
    )
    assert tag.valid?
  end

  # Normalizations
  test "name stripped of whitespace" do
    tag = Tag.new(
      user: users(:alice),
      name: "  Padded Name  "
    )
    tag.validate
    assert_equal "Padded Name", tag.name
  end

  # Associations
  test "belongs to user" do
    assert_equal users(:alice), tags(:tech).user
  end

  test "has many subscriber tags" do
    assert_respond_to tags(:tech), :subscriber_tags
  end

  test "has many subscribers through subscriber_tags" do
    assert_respond_to tags(:tech), :subscribers
    assert_includes tags(:tech).subscribers, subscribers(:tagged_subscriber)
  end

  test "has many newsletter tags" do
    assert_respond_to tags(:tech), :newsletter_tags
  end

  test "has many newsletters through newsletter_tags" do
    assert_respond_to tags(:tech), :newsletters
    assert_includes tags(:tech).newsletters, newsletters(:scheduled_newsletter)
  end

  # Scopes
  test "for_user scope" do
    alice_tags = Tag.for_user(users(:alice))
    assert_includes alice_tags, tags(:tech)
    assert_includes alice_tags, tags(:sports)
    assert_not_includes alice_tags, tags(:bob_general)
  end

  test "alphabetical scope" do
    alice_tags = Tag.for_user(users(:alice)).alphabetical
    names = alice_tags.pluck(:name)
    assert_equal names.sort, names
  end

  # Methods
  test "subscriber_count returns count of subscribers" do
    assert_equal 1, tags(:tech).subscriber_count
  end

  test "subscriber_count returns zero for tag with no subscribers" do
    assert_equal 0, tags(:news).subscriber_count
  end

  # Dependent destroy
  test "destroying tag destroys subscriber_tags" do
    tag = tags(:tech)
    subscriber_tag_count = tag.subscriber_tags.count
    assert subscriber_tag_count > 0

    # Also count signup_form_tags and newsletter_tags that will be destroyed
    signup_form_tag_count = tag.signup_form_tags.count
    newsletter_tag_count = tag.newsletter_tags.count

    assert_difference "SubscriberTag.count", -subscriber_tag_count do
      assert_difference "SignupFormTag.count", -signup_form_tag_count do
        assert_difference "NewsletterTag.count", -newsletter_tag_count do
          tag.destroy
        end
      end
    end
  end

  test "destroying tag destroys newsletter_tags" do
    # Use a tag that only has newsletter_tags
    tag = tags(:news)
    # Add a newsletter_tag to this tag for testing
    NewsletterTag.create!(newsletter: newsletters(:draft_newsletter), tag: tag)

    assert_difference "NewsletterTag.count", -1 do
      tag.destroy
    end
  end

  test "destroying tag destroys signup_form_tags" do
    tag = tags(:tech)
    signup_form_tag_count = tag.signup_form_tags.count
    assert signup_form_tag_count > 0

    # This also destroys subscriber_tags and newsletter_tags
    tag.destroy
    assert_equal 0, SignupFormTag.where(tag_id: tag.id).count
  end
end
