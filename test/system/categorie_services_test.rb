require "application_system_test_case"

class CategorieServicesTest < ApplicationSystemTestCase
  setup do
    @categorie_service = categorie_services(:one)
  end

  test "visiting the index" do
    visit categorie_services_url
    assert_selector "h1", text: "Categorie Services"
  end

  test "creating a Categorie service" do
    visit categorie_services_url
    click_on "New Categorie Service"

    fill_in "Detail", with: @categorie_service.detail
    fill_in "Name", with: @categorie_service.name
    click_on "Create Categorie service"

    assert_text "Categorie service was successfully created"
    click_on "Back"
  end

  test "updating a Categorie service" do
    visit categorie_services_url
    click_on "Edit", match: :first

    fill_in "Detail", with: @categorie_service.detail
    fill_in "Name", with: @categorie_service.name
    click_on "Update Categorie service"

    assert_text "Categorie service was successfully updated"
    click_on "Back"
  end

  test "destroying a Categorie service" do
    visit categorie_services_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Categorie service was successfully destroyed"
  end
end
