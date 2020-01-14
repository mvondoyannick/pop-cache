require 'test_helper'

class ParametresControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get parametres_index_url
    assert_response :success
  end

end
