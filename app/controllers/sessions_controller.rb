class SessionsController < ApplicationController
  before_action :require_no_authentication!, only: [ :new, :create ]
  before_action :require_authentication!, only: [ :destroy ]

  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      if user.confirmed?
        sign_in(user, remember: params[:remember_me] == "1")
        redirect_to stored_location_or(dashboard_path), notice: "Welcome back, #{user.name}!"
      else
        redirect_to new_session_path, alert: "Please confirm your email address first."
      end
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out
    redirect_to new_session_path, notice: "You have been signed out."
  end
end
