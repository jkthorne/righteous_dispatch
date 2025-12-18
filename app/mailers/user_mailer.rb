class UserMailer < ApplicationMailer
  def confirmation(user)
    @user = user
    @confirmation_url = confirm_email_url(token: user.confirmation_token)
    mail(to: user.email, subject: "Confirm your RighteousDispatch account")
  end

  def password_reset(user)
    @user = user
    @reset_url = edit_password_url(token: user.password_reset_token)
    mail(to: user.email, subject: "Reset your RighteousDispatch password")
  end
end
