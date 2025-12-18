class PublicSignupsController < ApplicationController
  layout false

  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :set_signup_form

  def show
    # Display the standalone signup form page
  end

  def create
    email = params[:email]&.strip&.downcase
    name = params[:name]&.strip

    if email.blank? || !email.match?(URI::MailTo::EMAIL_REGEXP)
      respond_to do |format|
        format.html { redirect_to public_signup_path(@signup_form.public_id), alert: "Please enter a valid email address." }
        format.json { render json: { success: false, error: "Please enter a valid email address." }, status: :unprocessable_entity }
      end
      return
    end

    subscriber = @signup_form.user.subscribers.find_or_initialize_by(email: email)
    is_new_subscriber = subscriber.new_record?

    if is_new_subscriber
      subscriber.first_name = name if name.present?
      subscriber.first_name ||= email.split("@").first.titleize
      subscriber.status = "confirmed"
      subscriber.subscribed_at = Time.current
      subscriber.confirmed_at = Time.current
    end

    if subscriber.save
      # Apply tags from signup form
      @signup_form.tags.each do |tag|
        subscriber.tags << tag unless subscriber.tags.include?(tag)
      end

      # Send welcome email for new subscribers
      if is_new_subscriber && @signup_form.user.welcome_email_enabled?
        SubscriberMailer.welcome(subscriber: subscriber).deliver_later
      end

      respond_to do |format|
        format.html { redirect_to public_signup_path(@signup_form.public_id), notice: @signup_form.success_message }
        format.json { render json: { success: true, message: @signup_form.success_message } }
      end
    else
      respond_to do |format|
        format.html { redirect_to public_signup_path(@signup_form.public_id), alert: subscriber.errors.full_messages.join(", ") }
        format.json { render json: { success: false, error: subscriber.errors.full_messages.join(", ") }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_signup_form
    @signup_form = SignupForm.active.find_by!(public_id: params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { render plain: "Form not found", status: :not_found }
      format.json { render json: { error: "Form not found" }, status: :not_found }
    end
  end
end
