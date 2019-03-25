require "application_system_test_case"

class CategoriesTest < ApplicationSystemTestCase
  setup do
    @category = categories(:one)
  end

  test "visiting the index" do
    visit categories_url
    assert_selector "h1", text: "Categories"
  end

  test "creating a Categorie" do
    visit categories_url
    click_on "New Categorie"

    fill_in "Detail", with: @category.detail
    fill_in "Name", with: @category.name
    click_on "Create Categorie"

    assert_text "Categorie was successfully created"
    click_on "Back"
  end

  test "updating a Categorie" do
    visit categories_url
    click_on "Edit", match: :first

    fill_in "Detail", with: @category.detail
    fill_in "Name", with: @category.name
    click_on "Update Categorie"

    assert_text "Categorie was successfully updated"
    click_on "Back"
  end

  test "destroying a Categorie" do
    visit categories_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Categorie was successfully destroyed"
  end
end
