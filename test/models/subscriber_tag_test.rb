require "test_helper"

class SubscriberTagTest < ActiveSupport::TestCase
  test "valid subscriber tag" do
    subscriber_tag = SubscriberTag.new(
      subscriber: subscribers(:confirmed_subscriber),
      tag: tags(:news)
    )
    assert subscriber_tag.valid?
  end

  test "belongs to subscriber" do
    assert_equal subscribers(:tagged_subscriber), subscriber_tags(:tagged_tech).subscriber
  end

  test "belongs to tag" do
    assert_equal tags(:tech), subscriber_tags(:tagged_tech).tag
  end

  test "uniqueness of subscriber_id scoped to tag_id" do
    duplicate = SubscriberTag.new(
      subscriber: subscriber_tags(:tagged_tech).subscriber,
      tag: subscriber_tags(:tagged_tech).tag
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:subscriber_id], "has already been taken"
  end

  test "same subscriber can have multiple tags" do
    subscriber = subscribers(:tagged_subscriber)
    new_tag = SubscriberTag.new(
      subscriber: subscriber,
      tag: tags(:news)
    )
    assert new_tag.valid?
  end

  test "same tag can have multiple subscribers" do
    tag = tags(:tech)
    new_subscriber_tag = SubscriberTag.new(
      subscriber: subscribers(:confirmed_subscriber),
      tag: tag
    )
    assert new_subscriber_tag.valid?
  end
end
