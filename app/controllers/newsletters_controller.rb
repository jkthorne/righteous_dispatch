class NewslettersController < ApplicationController
  before_action :require_authentication!
  before_action :set_newsletter, only: [ :show, :edit, :update, :destroy ]

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

  private

  def set_newsletter
    @newsletter = current_user.newsletters.find(params[:id])
  end

  def newsletter_params
    params.require(:newsletter).permit(:title, :subject, :preview_text, :content, :status)
  end
end
