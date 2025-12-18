module CurrentUser
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :signed_in?
    before_action :set_current_user
  end

  def current_user
    @current_user
  end

  def signed_in?
    current_user.present?
  end

  def require_authentication!
    unless signed_in?
      store_location!
      redirect_to new_session_path, alert: "Please sign in to continue."
    end
  end

  def require_no_authentication!
    if signed_in?
      redirect_to dashboard_path, notice: "You are already signed in."
    end
  end

  def sign_in(user, remember: false)
    if remember
      user.regenerate_remember_token!
      cookies.signed.permanent[:remember_token] = {
        value: user.remember_token,
        httponly: true,
        secure: Rails.env.production?
      }
    else
      session[:user_id] = user.id
    end
    @current_user = user
  end

  def sign_out
    cookies.delete(:remember_token)
    session.delete(:user_id)
    @current_user = nil
  end

  private

  def set_current_user
    @current_user = if session[:user_id]
      User.find_by(id: session[:user_id])
    elsif cookies.signed[:remember_token]
      User.find_by(remember_token: cookies.signed[:remember_token])
    end
  end

  def store_location!
    session[:return_to] = request.fullpath if request.get?
  end

  def stored_location_or(default)
    session.delete(:return_to) || default
  end
end
