class User < ApplicationRecord
  has_secure_password reset_token: false

  # Associations - order matters for dependent: :destroy
  # signup_forms and newsletters have join tables referencing tags
  # so they must be destroyed before tags
  has_many :signup_forms, dependent: :destroy
  has_many :newsletters, dependent: :destroy
  has_many :subscribers, dependent: :destroy
  has_many :tags, dependent: :destroy

  before_create :set_confirmation_token
  before_create :set_remember_token

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  normalizes :email, with: ->(email) { email.strip.downcase }

  def confirmed?
    confirmed_at.present?
  end

  def confirm!
    update!(confirmed_at: Time.current, confirmation_token: nil)
  end

  def generate_confirmation_token!
    update!(
      confirmation_token: SecureRandom.urlsafe_base64(32),
      confirmation_sent_at: Time.current
    )
  end

  def generate_password_reset_token!
    update!(
      password_reset_token: SecureRandom.urlsafe_base64(32),
      password_reset_sent_at: Time.current
    )
  end

  def password_reset_token_valid?
    password_reset_sent_at.present? && password_reset_sent_at > 2.hours.ago
  end

  def clear_password_reset_token!
    update!(password_reset_token: nil, password_reset_sent_at: nil)
  end

  def regenerate_remember_token!
    update!(
      remember_token: SecureRandom.urlsafe_base64(32),
      remember_created_at: Time.current
    )
  end

  private

  def set_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64(32)
    self.confirmation_sent_at = Time.current
  end

  def set_remember_token
    self.remember_token = SecureRandom.urlsafe_base64(32)
    self.remember_created_at = Time.current
  end
end
