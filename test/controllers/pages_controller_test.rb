require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get pages_index_url
    assert_response :success
  end

  test "should get user_index" do
    get pages_user_index_url
    assert_response :success
  end

end
