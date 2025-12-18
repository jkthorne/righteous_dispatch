class SendNewsletterEmailJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(newsletter_id, subscriber_id)
    newsletter = Newsletter.find_by(id: newsletter_id)
    subscriber = Subscriber.find_by(id: subscriber_id)

    return unless newsletter && subscriber
    return unless subscriber.confirmed?

    NewsletterMailer.newsletter(newsletter: newsletter, subscriber: subscriber).deliver_now
  end
end
