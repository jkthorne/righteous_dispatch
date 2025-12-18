class Newsletter < ApplicationRecord
  belongs_to :user
  has_rich_text :content
  has_many :newsletter_tags, dependent: :destroy
  has_many :tags, through: :newsletter_tags

  # Status enum
  enum :status, {
    draft: "draft",
    scheduled: "scheduled",
    sending: "sending",
    sent: "sent"
  }, default: :draft

  # Scopes
  scope :for_user, ->(user) { where(user: user) }
  scope :drafts, -> { where(status: :draft) }
  scope :scheduled, -> { where(status: :scheduled) }
  scope :sent, -> { where(status: :sent) }
  scope :recent, -> { order(updated_at: :desc) }
  scope :ready_to_send, -> { scheduled.where("scheduled_at <= ?", Time.current) }

  # Validations
  validates :title, presence: true
  validates :subject, presence: true, on: :send
  validates :content, presence: true, on: :send

  # Check if newsletter is ready to send
  def ready_to_send?
    title.present? && subject.present? && content.present?
  end

  # Mark as scheduled
  def schedule!(time)
    update!(status: :scheduled, scheduled_at: time)
  end

  # Mark as sent
  def mark_sent!
    update!(status: :sent, sent_at: Time.current)
  end

  # Check if newsletter has tag filters
  def has_tag_filters?
    tags.any?
  end

  # Get recipients based on tag filters
  def recipients
    if has_tag_filters?
      user.subscribers.confirmed.joins(:tags).where(tags: { id: tag_ids }).distinct
    else
      user.subscribers.confirmed
    end
  end
end
