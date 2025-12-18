class NewsletterMailer < ApplicationMailer
  helper TrackingHelper

  def newsletter(newsletter:, subscriber:)
    @newsletter = newsletter
    @subscriber = subscriber
    @user = newsletter.user
    @unsubscribe_url = unsubscribe_url(token: subscriber.unsubscribe_token)
    @view_in_browser_url = public_newsletter_url(id: newsletter.id, token: subscriber.unsubscribe_token)
    @tracking_pixel_url = tracking_pixel_url(newsletter: newsletter, subscriber: subscriber)

    mail(
      to: subscriber.email,
      subject: newsletter.subject,
      from: "#{@user.name} <#{default_from_address}>"
    )
  end

  private

  def default_from_address
    Rails.application.config.action_mailer.default_options&.dig(:from) || "noreply@righteousdispatch.com"
  end

  def tracking_pixel_url(newsletter:, subscriber:)
    token = Rails.application.message_verifier(:tracking).generate(
      { newsletter_id: newsletter.id, subscriber_id: subscriber.id },
      expires_in: 1.year
    )
    tracking_open_url(token: token)
  end
end
