require "test_helper"

class SignupFormsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:alice)
  end

  test "all actions require authentication" do
    delete session_path
    get signup_forms_path
    assert_redirected_to new_session_path
  end

  test "index returns user forms" do
    get signup_forms_path
    assert_response :success
  end

  test "show uses public_id" do
    form = signup_forms(:active_form)
    get signup_form_path(form.public_id)
    assert_response :success
  end

  test "new renders form" do
    get new_signup_form_path
    assert_response :success
    assert_select "form"
  end

  test "create with valid params" do
    assert_difference "SignupForm.count", 1 do
      post signup_forms_path, params: {
        signup_form: {
          title: "New Form",
          headline: "Join Us",
          description: "Get updates"
        }
      }
    end
    # Redirects to show page, not index
    assert_response :redirect
  end

  test "create with tags" do
    assert_difference "SignupForm.count", 1 do
      post signup_forms_path, params: {
        signup_form: {
          title: "Tagged Form",
          tag_ids: [tags(:tech).id]
        }
      }
    end
    form = SignupForm.last
    assert_includes form.tags, tags(:tech)
  end

  test "create with invalid params" do
    assert_no_difference "SignupForm.count" do
      post signup_forms_path, params: {
        signup_form: { title: "" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "edit displays form" do
    get edit_signup_form_path(signup_forms(:active_form).public_id)
    assert_response :success
    assert_select "form"
  end

  test "update with valid params" do
    form = signup_forms(:active_form)
    patch signup_form_path(form.public_id), params: {
      signup_form: { title: "Updated Title" }
    }
    # Redirects to show page, not index
    assert_redirected_to signup_form_path(form.public_id)
    assert_equal "Updated Title", form.reload.title
  end

  test "destroy removes form" do
    form = signup_forms(:inactive_form)
    assert_difference "SignupForm.count", -1 do
      delete signup_form_path(form.public_id)
    end
    assert_redirected_to signup_forms_path
  end

  test "accessing other users form fails" do
    get signup_form_path(signup_forms(:bob_form).public_id)
    assert_response :not_found
  end
end
