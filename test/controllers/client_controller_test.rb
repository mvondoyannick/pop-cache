require 'test_helper'

class ClientControllerTest < ActionDispatch::IntegrationTest
  test "should get signing" do
    get client_signing_url
    assert_response :success
  end

  test "should get signup" do
    get client_signup_url
    assert_response :success
  end

  test "should get parameters" do
    get client_parameters_url
    assert_response :success
  end

  test "should get index" do
    get client_index_url
    assert_response :success
  end

end
