require 'test_helper'

class VerifyControllerTest < ActionDispatch::IntegrationTest
  test "should get query" do
    get verify_query_url
    assert_response :success
  end

  test "should get verify" do
    get verify_verify_url
    assert_response :success
  end

end
