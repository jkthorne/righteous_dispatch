class SubscribersController < ApplicationController
  before_action :require_authentication!
  before_action :set_subscriber, only: [ :show, :edit, :update, :destroy ]

  def index
    @subscribers = current_user.subscribers.recent
    @subscribers = @subscribers.with_tag(params[:tag]) if params[:tag].present?

    if params[:status].present?
      @subscribers = @subscribers.where(status: params[:status])
    end
  end

  def show
  end

  def new
    @subscriber = current_user.subscribers.build
  end

  def create
    @subscriber = current_user.subscribers.build(subscriber_params)

    if @subscriber.save
      redirect_to subscribers_path, notice: "Subscriber added successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @subscriber.update(subscriber_params)
      redirect_to subscribers_path, notice: "Subscriber updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @subscriber.destroy
    redirect_to subscribers_path, notice: "Subscriber deleted successfully."
  end

  # CSV Import
  def import
  end

  def process_import
    unless params[:file].present?
      redirect_to import_subscribers_path, alert: "Please select a CSV file."
      return
    end

    file = params[:file]
    imported = 0
    errors = []

    require "csv"
    CSV.foreach(file.path, headers: true, header_converters: :symbol) do |row|
      subscriber = current_user.subscribers.build(
        email: row[:email],
        first_name: row[:first_name] || row[:name]&.split&.first,
        last_name: row[:last_name] || row[:name]&.split&.drop(1)&.join(" "),
        status: :confirmed
      )

      if subscriber.save
        imported += 1
      else
        errors << "#{row[:email]}: #{subscriber.errors.full_messages.join(', ')}"
      end
    end

    if errors.any?
      flash[:alert] = "Imported #{imported} subscribers. #{errors.size} errors: #{errors.first(3).join('; ')}"
    else
      flash[:notice] = "Successfully imported #{imported} subscribers."
    end

    redirect_to subscribers_path
  rescue CSV::MalformedCSVError => e
    redirect_to import_subscribers_path, alert: "Invalid CSV file: #{e.message}"
  end

  private

  def set_subscriber
    @subscriber = current_user.subscribers.find(params[:id])
  end

  def subscriber_params
    params.require(:subscriber).permit(:email, :first_name, :last_name, :status, tag_ids: [])
  end
end
