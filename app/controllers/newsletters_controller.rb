class NewslettersController < ApplicationController
  before_action :require_authentication!
  before_action :set_newsletter, only: [ :show, :edit, :update, :destroy, :preview, :confirm_send, :send_newsletter, :schedule, :update_tags ]

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
    @tags = current_user.tags
    @recipient_count = @newsletter.recipients.count

    unless @newsletter.ready_to_send?
      redirect_to edit_newsletter_path(@newsletter), alert: "Newsletter is missing required fields (title, subject, or content)."
      return
    end

    if current_user.subscribers.confirmed.count.zero?
      redirect_to edit_newsletter_path(@newsletter), alert: "You have no confirmed subscribers to send to."
      return
    end
  end

  def update_tags
    tag_ids = params[:tag_ids]&.map(&:to_i) || []
    @newsletter.tag_ids = tag_ids
    redirect_to confirm_send_newsletter_path(@newsletter), notice: "Audience updated."
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

    recipient_count = @newsletter.recipients.count
    @newsletter.update!(status: :sending)
    SendNewsletterJob.perform_later(@newsletter.id)

    redirect_to newsletters_path, notice: "Newsletter is being sent to #{recipient_count} subscribers."
  end

  def schedule
    unless @newsletter.ready_to_send?
      redirect_to edit_newsletter_path(@newsletter), alert: "Newsletter is missing required fields."
      return
    end

    if @newsletter.sent?
      redirect_to newsletters_path, alert: "This newsletter has already been sent."
      return
    end

    scheduled_at = parse_scheduled_time
    if scheduled_at.nil?
      redirect_to confirm_send_newsletter_path(@newsletter), alert: "Please select a valid date and time."
      return
    end

    if scheduled_at <= Time.current
      redirect_to confirm_send_newsletter_path(@newsletter), alert: "Scheduled time must be in the future."
      return
    end

    @newsletter.schedule!(scheduled_at)
    redirect_to newsletters_path, notice: "Newsletter scheduled for #{scheduled_at.strftime('%B %d, %Y at %I:%M %p')}."
  end

  private

  def parse_scheduled_time
    date = params[:scheduled_date]
    time = params[:scheduled_time]
    return nil if date.blank? || time.blank?

    Time.zone.parse("#{date} #{time}")
  rescue ArgumentError
    nil
  end

  def set_newsletter
    @newsletter = current_user.newsletters.find(params[:id])
  end

  def newsletter_params
    params.require(:newsletter).permit(:title, :subject, :preview_text, :content, :status, :scheduled_at)
  end
end
