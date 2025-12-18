class UnsubscribesController < ApplicationController
  skip_before_action :set_current_user, only: [ :show, :create ]

  def show
    @subscriber = Subscriber.find_by(unsubscribe_token: params[:token])

    unless @subscriber
      redirect_to root_path, alert: "Invalid unsubscribe link."
    end
  end

  def create
    @subscriber = Subscriber.find_by(unsubscribe_token: params[:token])

    unless @subscriber
      redirect_to root_path, alert: "Invalid unsubscribe link."
      return
    end

    if @subscriber.unsubscribed?
      redirect_to unsubscribe_path(token: params[:token]), notice: "You have already unsubscribed."
      return
    end

    @subscriber.unsubscribe!
    redirect_to unsubscribe_path(token: params[:token]), notice: "You have been successfully unsubscribed."
  end
end
