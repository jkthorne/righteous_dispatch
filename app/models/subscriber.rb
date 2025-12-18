class Subscriber < ApplicationRecord
  belongs_to :user
  has_many :subscriber_tags, dependent: :destroy
  has_many :tags, through: :subscriber_tags
  has_many :email_events, dependent: :destroy

  # Status enum
  enum :status, {
    pending: "pending",
    confirmed: "confirmed",
    unsubscribed: "unsubscribed",
    bounced: "bounced"
  }, default: :pending

  # Scopes
  scope :for_user, ->(user) { where(user: user) }
  scope :active, -> { where(status: [ :pending, :confirmed ]) }
  scope :confirmed, -> { where(status: :confirmed) }
  scope :recent, -> { order(created_at: :desc) }
  scope :with_tag, ->(tag) { joins(:tags).where(tags: { id: tag }) }

  # Validations
  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :user_id, case_sensitive: false }

  # Normalize email
  normalizes :email, with: ->(email) { email.strip.downcase }

  # Callbacks
  before_create :set_confirmation_token
  before_create :set_unsubscribe_token
  before_create :set_subscribed_at

  # Full name helper
  def full_name
    [ first_name, last_name ].compact.join(" ").presence || email
  end

  # Display name (first name or email)
  def display_name
    first_name.presence || email.split("@").first
  end

  # Confirm subscription
  def confirm!
    update!(
      status: :confirmed,
      confirmed_at: Time.current,
      confirmation_token: nil
    )
  end

  # Unsubscribe
  def unsubscribe!
    update!(
      status: :unsubscribed,
      unsubscribed_at: Time.current
    )
  end

  # Check if confirmed
  def confirmed?
    status == "confirmed"
  end

  private

  def set_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64(32)
  end

  def set_unsubscribe_token
    self.unsubscribe_token = SecureRandom.urlsafe_base64(32)
  end

  def set_subscribed_at
    self.subscribed_at = Time.current
  end
end
