require 'test_helper'

class BingoCardsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get bingo_cards_create_url
    assert_response :success
  end

  test "should get show" do
    get bingo_cards_show_url
    assert_response :success
  end

end
