class SendNewsletterJob < ApplicationJob
  queue_as :default

  def perform(newsletter_id)
    newsletter = Newsletter.find_by(id: newsletter_id)
    return unless newsletter
    return unless newsletter.status == "sending"

    user = newsletter.user
    subscribers = user.subscribers.confirmed

    subscribers.find_each do |subscriber|
      SendNewsletterEmailJob.perform_later(newsletter_id, subscriber.id)
    end

    # Mark as sent after all emails are queued
    newsletter.mark_sent!
  end
end
