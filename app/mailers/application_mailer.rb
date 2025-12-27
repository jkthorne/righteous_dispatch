class ApplicationMailer < ActionMailer::Base
  default from: -> { ApplicationMailer.default_from_address }
  layout "mailer"

  def self.default_from_address
    ENV.fetch("MAILER_FROM", "RighteousDispatch <noreply@righteousdispatch.com>")
  end
end
