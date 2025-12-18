class SubscriberMailer < ApplicationMailer
  def welcome(subscriber:)
    @subscriber = subscriber
    @user = subscriber.user
    @unsubscribe_url = unsubscribe_url(token: subscriber.unsubscribe_token)

    return unless @user.welcome_email_enabled?
    return if @user.welcome_email_subject.blank?

    mail(
      to: subscriber.email,
      subject: @user.welcome_email_subject,
      from: "#{@user.name} <#{default_from_address}>"
    )
  end

  private

  def default_from_address
    Rails.application.config.action_mailer.default_options&.dig(:from) || "noreply@righteousdispatch.com"
  end
end
