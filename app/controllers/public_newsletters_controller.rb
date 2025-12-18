class PublicNewslettersController < ApplicationController
  skip_before_action :set_current_user

  def show
    @newsletter = Newsletter.find_by(id: params[:id])
    @subscriber = Subscriber.find_by(unsubscribe_token: params[:token])

    unless @newsletter && @subscriber
      redirect_to root_path, alert: "Newsletter not found."
      return
    end

    # Verify the subscriber belongs to the newsletter's user
    unless @subscriber.user_id == @newsletter.user_id
      redirect_to root_path, alert: "Newsletter not found."
      return
    end

    @user = @newsletter.user
    @unsubscribe_url = unsubscribe_url(token: @subscriber.unsubscribe_token)
  end
end
