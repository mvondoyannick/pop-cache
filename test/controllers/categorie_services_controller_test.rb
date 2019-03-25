require 'test_helper'

class CategorieServicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @categorie_service = categorie_services(:one)
  end

  test "should get index" do
    get categorie_services_url
    assert_response :success
  end

  test "should get new" do
    get new_categorie_service_url
    assert_response :success
  end

  test "should create categorie_service" do
    assert_difference('CategorieService.count') do
      post categorie_services_url, params: { categorie_service: { detail: @categorie_service.detail, name: @categorie_service.name } }
    end

    assert_redirected_to categorie_service_url(CategorieService.last)
  end

  test "should show categorie_service" do
    get categorie_service_url(@categorie_service)
    assert_response :success
  end

  test "should get edit" do
    get edit_categorie_service_url(@categorie_service)
    assert_response :success
  end

  test "should update categorie_service" do
    patch categorie_service_url(@categorie_service), params: { categorie_service: { detail: @categorie_service.detail, name: @categorie_service.name } }
    assert_redirected_to categorie_service_url(@categorie_service)
  end

  test "should destroy categorie_service" do
    assert_difference('CategorieService.count', -1) do
      delete categorie_service_url(@categorie_service)
    end

    assert_redirected_to categorie_services_url
  end
end
