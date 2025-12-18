class SettingsController < ApplicationController
  before_action :require_authentication!

  def show
  end

  def update
    if current_user.update(user_params)
      redirect_to settings_path, notice: "Settings updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def update_password
    unless current_user.authenticate(params[:current_password])
      current_user.errors.add(:current_password, "is incorrect")
      render :show, status: :unprocessable_entity
      return
    end

    if current_user.update(password_params)
      redirect_to settings_path, notice: "Password changed successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    unless current_user.authenticate(params[:password])
      current_user.errors.add(:password, "is incorrect")
      render :show, status: :unprocessable_entity
      return
    end

    current_user.destroy
    sign_out
    redirect_to root_path, notice: "Your account has been deleted."
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :welcome_email_enabled, :welcome_email_subject, :welcome_email_content)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
