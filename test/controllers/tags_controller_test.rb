require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:alice)
  end

  test "index requires authentication" do
    delete session_path
    get tags_path
    assert_redirected_to new_session_path
  end

  test "index returns user tags" do
    get tags_path
    assert_response :success
  end

  test "create with valid params" do
    assert_difference "Tag.count", 1 do
      post tags_path, params: {
        tag: { name: "New Tag", color: "#ff0000" }
      }
    end
    assert_redirected_to tags_path
  end

  test "create with invalid params" do
    assert_no_difference "Tag.count" do
      post tags_path, params: {
        tag: { name: "" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "create with duplicate name fails" do
    assert_no_difference "Tag.count" do
      post tags_path, params: {
        tag: { name: tags(:tech).name }
      }
    end
    assert_response :unprocessable_entity
  end

  test "destroy removes tag" do
    tag = tags(:news) # Use a tag without associations
    assert_difference "Tag.count", -1 do
      delete tag_path(tag)
    end
    assert_redirected_to tags_path
  end

  test "destroy other users tag fails" do
    delete tag_path(tags(:bob_general))
    assert_response :not_found
  end
end
