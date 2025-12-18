class NewsletterMailer < ApplicationMailer
  def newsletter(newsletter:, subscriber:)
    @newsletter = newsletter
    @subscriber = subscriber
    @user = newsletter.user
    @unsubscribe_url = unsubscribe_url(token: subscriber.unsubscribe_token)
    @view_in_browser_url = public_newsletter_url(id: newsletter.id, token: subscriber.unsubscribe_token)

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
end
