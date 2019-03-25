require 'test_helper'

class AgentcrtlControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get agentcrtl_index_url
    assert_response :success
  end

  test "should get new" do
    get agentcrtl_new_url
    assert_response :success
  end

  test "should get edit" do
    get agentcrtl_edit_url
    assert_response :success
  end

  test "should get delete" do
    get agentcrtl_delete_url
    assert_response :success
  end

end
