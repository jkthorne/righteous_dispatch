class PasswordsController < ApplicationController
  before_action :require_no_authentication!
  before_action :set_user_by_token, only: [ :edit, :update ]

  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user
      user.generate_password_reset_token!
      UserMailer.password_reset(user).deliver_later
    end

    # Always show success message to prevent email enumeration
    redirect_to new_session_path, notice: "If your email is registered, you will receive password reset instructions shortly."
  end

  def edit
  end

  def update
    if @user.update(password_params)
      @user.clear_password_reset_token!
      redirect_to new_session_path, notice: "Your password has been reset. Please sign in."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user_by_token
    @user = User.find_by(password_reset_token: params[:token])

    unless @user&.password_reset_token_valid?
      redirect_to new_password_path, alert: "Invalid or expired password reset link."
    end
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
