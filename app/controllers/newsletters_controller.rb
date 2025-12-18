class NewslettersController < ApplicationController
  before_action :require_authentication!
  before_action :set_newsletter, only: [ :show, :edit, :update, :destroy, :preview, :confirm_send, :send_newsletter ]

  def index
    @newsletters = current_user.newsletters.recent
  end

  def show
  end

  def new
    @newsletter = current_user.newsletters.build
  end

  def create
    @newsletter = current_user.newsletters.build(newsletter_params)

    if @newsletter.save
      redirect_to edit_newsletter_path(@newsletter), notice: "Newsletter created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @newsletter.update(newsletter_params)
      redirect_to edit_newsletter_path(@newsletter), notice: "Newsletter updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @newsletter.destroy
    redirect_to newsletters_path, notice: "Newsletter deleted successfully."
  end

  def preview
    @subscriber = current_user.subscribers.confirmed.first || Subscriber.new(
      email: current_user.email,
      first_name: current_user.name.split.first,
      last_name: current_user.name.split.last,
      unsubscribe_token: "preview"
    )
  end

  def confirm_send
    @subscriber_count = current_user.subscribers.confirmed.count

    unless @newsletter.ready_to_send?
      redirect_to edit_newsletter_path(@newsletter), alert: "Newsletter is missing required fields (title, subject, or content)."
      return
    end

    if @subscriber_count.zero?
      redirect_to edit_newsletter_path(@newsletter), alert: "You have no confirmed subscribers to send to."
      return
    end
  end

  def send_newsletter
    unless @newsletter.ready_to_send?
      redirect_to edit_newsletter_path(@newsletter), alert: "Newsletter is missing required fields."
      return
    end

    if @newsletter.sent?
      redirect_to newsletters_path, alert: "This newsletter has already been sent."
      return
    end

    @newsletter.update!(status: :sending)
    SendNewsletterJob.perform_later(@newsletter.id)

    redirect_to newsletters_path, notice: "Newsletter is being sent to #{current_user.subscribers.confirmed.count} subscribers."
  end

  private

  def set_newsletter
    @newsletter = current_user.newsletters.find(params[:id])
  end

  def newsletter_params
    params.require(:newsletter).permit(:title, :subject, :preview_text, :content, :status)
  end
end
