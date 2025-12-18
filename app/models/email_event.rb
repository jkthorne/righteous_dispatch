class EmailEvent < ApplicationRecord
  belongs_to :newsletter
  belongs_to :subscriber

  # Event types
  OPEN = "open".freeze
  CLICK = "click".freeze
  BOUNCE = "bounce".freeze
  COMPLAINT = "complaint".freeze

  EVENT_TYPES = [OPEN, CLICK, BOUNCE, COMPLAINT].freeze

  # Validations
  validates :event_type, presence: true, inclusion: { in: EVENT_TYPES }

  # Scopes
  scope :opens, -> { where(event_type: OPEN) }
  scope :clicks, -> { where(event_type: CLICK) }
  scope :bounces, -> { where(event_type: BOUNCE) }
  scope :complaints, -> { where(event_type: COMPLAINT) }
  scope :for_newsletter, ->(newsletter) { where(newsletter: newsletter) }

  # Record an open event (only once per subscriber per newsletter)
  def self.record_open(newsletter:, subscriber:, ip_address: nil, user_agent: nil)
    create_with(
      ip_address: ip_address,
      user_agent: user_agent
    ).find_or_create_by(
      newsletter: newsletter,
      subscriber: subscriber,
      event_type: OPEN
    )
  end

  # Record a click event (multiple clicks allowed)
  def self.record_click(newsletter:, subscriber:, url:, ip_address: nil, user_agent: nil)
    create!(
      newsletter: newsletter,
      subscriber: subscriber,
      event_type: CLICK,
      metadata: { url: url },
      ip_address: ip_address,
      user_agent: user_agent
    )
  end
end
