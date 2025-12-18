class SignupFormsController < ApplicationController
  before_action :require_authentication!
  before_action :set_signup_form, only: [:show, :edit, :update, :destroy]

  def index
    @signup_forms = current_user.signup_forms.order(created_at: :desc)
  end

  def show
  end

  def new
    @signup_form = current_user.signup_forms.build
    @tags = current_user.tags.order(:name)
  end

  def create
    @signup_form = current_user.signup_forms.build(signup_form_params)

    if @signup_form.save
      redirect_to signup_form_path(@signup_form), notice: "Signup form created successfully."
    else
      @tags = current_user.tags.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @tags = current_user.tags.order(:name)
  end

  def update
    if @signup_form.update(signup_form_params)
      redirect_to signup_form_path(@signup_form), notice: "Signup form updated successfully."
    else
      @tags = current_user.tags.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @signup_form.destroy
    redirect_to signup_forms_path, notice: "Signup form deleted successfully."
  end

  private

  def set_signup_form
    @signup_form = current_user.signup_forms.find_by!(public_id: params[:id])
  end

  def signup_form_params
    params.require(:signup_form).permit(:title, :headline, :description, :button_text, :success_message, :active, tag_ids: [])
  end
end
