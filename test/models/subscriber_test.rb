require "test_helper"

class SubscriberTest < ActiveSupport::TestCase
  # Validations
  test "valid subscriber" do
    subscriber = Subscriber.new(
      user: users(:alice),
      email: "new@example.com",
      first_name: "New",
      last_name: "Subscriber"
    )
    assert subscriber.valid?
  end

  test "email presence required" do
    subscriber = subscribers(:confirmed_subscriber)
    subscriber.email = nil
    assert_not subscriber.valid?
    assert_includes subscriber.errors[:email], "can't be blank"
  end

  test "email format validation" do
    subscriber = subscribers(:confirmed_subscriber)
    subscriber.email = "invalid-email"
    assert_not subscriber.valid?
    assert_includes subscriber.errors[:email], "is invalid"
  end

  test "email uniqueness scoped to user" do
    subscriber = Subscriber.new(
      user: users(:alice),
      email: subscribers(:confirmed_subscriber).email
    )
    assert_not subscriber.valid?
    assert_includes subscriber.errors[:email], "has already been taken"
  end

  test "email uniqueness case insensitive" do
    subscriber = Subscriber.new(
      user: users(:alice),
      email: subscribers(:confirmed_subscriber).email.upcase
    )
    assert_not subscriber.valid?
    assert_includes subscriber.errors[:email], "has already been taken"
  end

  test "same email allowed for different users" do
    subscriber = Subscriber.new(
      user: users(:bob),
      email: subscribers(:confirmed_subscriber).email
    )
    assert subscriber.valid?
  end

  # Normalizations
  test "email normalized to lowercase" do
    subscriber = Subscriber.new(
      user: users(:alice),
      email: "  TEST@EXAMPLE.COM  "
    )
    subscriber.validate
    assert_equal "test@example.com", subscriber.email
  end

  # Callbacks
  test "confirmation token set on create" do
    subscriber = Subscriber.create!(
      user: users(:alice),
      email: "new@example.com"
    )
    assert_not_nil subscriber.confirmation_token
  end

  test "unsubscribe token set on create" do
    subscriber = Subscriber.create!(
      user: users(:alice),
      email: "new2@example.com"
    )
    assert_not_nil subscriber.unsubscribe_token
  end

  test "subscribed_at set on create" do
    subscriber = Subscriber.create!(
      user: users(:alice),
      email: "new3@example.com"
    )
    assert_not_nil subscriber.subscribed_at
  end

  # Associations
  test "belongs to user" do
    assert_equal users(:alice), subscribers(:confirmed_subscriber).user
  end

  test "has many subscriber tags" do
    assert_respond_to subscribers(:tagged_subscriber), :subscriber_tags
    assert_equal 2, subscribers(:tagged_subscriber).subscriber_tags.count
  end

  test "has many tags through subscriber_tags" do
    assert_respond_to subscribers(:tagged_subscriber), :tags
    assert_includes subscribers(:tagged_subscriber).tags, tags(:tech)
    assert_includes subscribers(:tagged_subscriber).tags, tags(:sports)
  end

  test "has many email events" do
    assert_respond_to subscribers(:confirmed_subscriber), :email_events
    assert subscribers(:confirmed_subscriber).email_events.count > 0
  end

  # Enum
  test "status enum values" do
    assert_equal "pending", Subscriber.statuses[:pending]
    assert_equal "confirmed", Subscriber.statuses[:confirmed]
    assert_equal "unsubscribed", Subscriber.statuses[:unsubscribed]
    assert_equal "bounced", Subscriber.statuses[:bounced]
  end

  test "default status is pending" do
    subscriber = Subscriber.new(user: users(:alice), email: "test@test.com")
    assert subscriber.pending?
  end

  # Scopes
  test "for_user scope" do
    alice_subscribers = Subscriber.for_user(users(:alice))
    assert_includes alice_subscribers, subscribers(:confirmed_subscriber)
    assert_not_includes alice_subscribers, subscribers(:bob_subscriber)
  end

  test "active scope includes pending and confirmed" do
    active = Subscriber.active
    assert_includes active, subscribers(:confirmed_subscriber)
    assert_includes active, subscribers(:pending_subscriber)
    assert_not_includes active, subscribers(:unsubscribed_subscriber)
  end

  test "confirmed scope" do
    confirmed = Subscriber.confirmed
    assert_includes confirmed, subscribers(:confirmed_subscriber)
    assert_not_includes confirmed, subscribers(:pending_subscriber)
    assert_not_includes confirmed, subscribers(:unsubscribed_subscriber)
  end

  test "recent scope orders by created_at desc" do
    recent = Subscriber.for_user(users(:alice)).recent
    dates = recent.pluck(:created_at)
    assert_equal dates.sort.reverse, dates
  end

  test "with_tag scope" do
    with_tech = Subscriber.with_tag(tags(:tech))
    assert_includes with_tech, subscribers(:tagged_subscriber)
    assert_not_includes with_tech, subscribers(:confirmed_subscriber)
  end

  # Methods
  test "full_name returns combined name" do
    subscriber = subscribers(:confirmed_subscriber)
    assert_equal "John Doe", subscriber.full_name
  end

  test "full_name returns email when no name" do
    subscriber = Subscriber.new(user: users(:alice), email: "noname@example.com")
    assert_equal "noname@example.com", subscriber.full_name
  end

  test "full_name with only first name" do
    subscriber = Subscriber.new(
      user: users(:alice),
      email: "first@example.com",
      first_name: "OnlyFirst"
    )
    assert_equal "OnlyFirst", subscriber.full_name
  end

  test "display_name returns first name" do
    subscriber = subscribers(:confirmed_subscriber)
    assert_equal "John", subscriber.display_name
  end

  test "display_name returns email prefix when no first name" do
    subscriber = Subscriber.new(user: users(:alice), email: "noname@example.com")
    assert_equal "noname", subscriber.display_name
  end

  test "confirm! updates status and clears token" do
    subscriber = subscribers(:pending_subscriber)
    assert subscriber.pending?
    assert_not_nil subscriber.confirmation_token

    subscriber.confirm!

    assert subscriber.confirmed?
    assert_nil subscriber.confirmation_token
    assert_not_nil subscriber.confirmed_at
  end

  test "unsubscribe! updates status and timestamp" do
    subscriber = subscribers(:confirmed_subscriber)
    assert subscriber.confirmed?

    subscriber.unsubscribe!

    assert subscriber.unsubscribed?
    assert_not_nil subscriber.unsubscribed_at
  end

  test "confirmed? returns true for confirmed status" do
    assert subscribers(:confirmed_subscriber).confirmed?
  end

  test "confirmed? returns false for pending status" do
    assert_not subscribers(:pending_subscriber).confirmed?
  end

  # Dependent destroy
  test "destroying subscriber destroys subscriber_tags" do
    subscriber = subscribers(:tagged_subscriber)
    tag_count = subscriber.subscriber_tags.count
    assert tag_count > 0

    assert_difference "SubscriberTag.count", -tag_count do
      subscriber.destroy
    end
  end

  test "destroying subscriber destroys email_events" do
    subscriber = subscribers(:confirmed_subscriber)
    event_count = subscriber.email_events.count
    assert event_count > 0

    assert_difference "EmailEvent.count", -event_count do
      subscriber.destroy
    end
  end
end
