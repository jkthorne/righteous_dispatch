class ConfirmationsController < ApplicationController
  before_action :require_no_authentication!, only: [ :new, :create ]

  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user && !user.confirmed?
      user.generate_confirmation_token!
      UserMailer.confirmation(user).deliver_later
    end

    # Always show success message to prevent email enumeration
    redirect_to new_session_path, notice: "If your email is registered, you will receive confirmation instructions shortly."
  end

  def show
    user = User.find_by(confirmation_token: params[:token])

    if user
      user.confirm!
      redirect_to new_session_path, notice: "Your email has been confirmed. Please sign in."
    else
      redirect_to new_session_path, alert: "Invalid or expired confirmation link."
    end
  end
end
