class ApplicationMailer < ActionMailer::Base
  default from: -> { default_from_address }
  layout "mailer"

  private

  def self.default_from_address
    ENV.fetch("MAILER_FROM", "RighteousDispatch <noreply@righteousdispatch.com>")
  end
end
