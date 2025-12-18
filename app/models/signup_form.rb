class SignupForm < ApplicationRecord
  belongs_to :user

  has_many :signup_form_tags, dependent: :destroy
  has_many :tags, through: :signup_form_tags

  validates :title, presence: true
  validates :public_id, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }

  before_validation :generate_public_id, on: :create

  def to_param
    public_id
  end

  private

  def generate_public_id
    self.public_id ||= SecureRandom.alphanumeric(10).downcase
  end
end
