class RegistrationsController < ApplicationController
  before_action :require_no_authentication!

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      UserMailer.confirmation(@user).deliver_later
      redirect_to new_session_path, notice: "Welcome! Please check your email to confirm your account."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name)
  end
end
