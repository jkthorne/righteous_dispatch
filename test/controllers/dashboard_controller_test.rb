require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "show requires authentication" do
    get dashboard_path
    assert_redirected_to new_session_path
    assert_match /sign in/, flash[:alert]
  end

  test "show renders dashboard" do
    sign_in_as users(:alice)
    get dashboard_path
    assert_response :success
  end
end
