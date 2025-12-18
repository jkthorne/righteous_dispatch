class TagsController < ApplicationController
  before_action :require_authentication!

  def index
    @tags = current_user.tags.order(:name)
    @tag = current_user.tags.build
  end

  def create
    @tag = current_user.tags.build(tag_params)

    if @tag.save
      redirect_to tags_path, notice: "Tag created successfully."
    else
      @tags = current_user.tags.order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @tag = current_user.tags.find(params[:id])
    @tag.destroy
    redirect_to tags_path, notice: "Tag deleted successfully."
  end

  private

  def tag_params
    params.require(:tag).permit(:name)
  end
end
