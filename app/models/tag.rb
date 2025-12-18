class Tag < ApplicationRecord
  belongs_to :user
  has_many :subscriber_tags, dependent: :destroy
  has_many :subscribers, through: :subscriber_tags
  has_many :newsletter_tags, dependent: :destroy
  has_many :newsletters, through: :newsletter_tags

  # Scopes
  scope :for_user, ->(user) { where(user: user) }
  scope :alphabetical, -> { order(:name) }

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false }

  # Normalize name
  normalizes :name, with: ->(name) { name.strip }

  # Subscriber count
  def subscriber_count
    subscribers.count
  end
end
