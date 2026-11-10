require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = categories(:one)
  end

  test "should get index" do
    get categories_url
    assert_response :success
  end

  test "should get new" do
    get new_category_url
    assert_response :success
  end

  test "should create category" do
    assert_difference("Category.count") do
      post categories_url, params: { category: { name: @category.name } }
    end

    assert_redirected_to categories_url
  end

  test "should show category" do
    get category_url(@category)
    assert_response :success
  end

  test "should get edit" do
    get edit_category_url(@category)
    assert_response :success
  end

  test "should update category" do
    patch category_url(@category), params: { category: { name: @category.name } }
    assert_redirected_to category_url(@category)
  end

  test "should destroy category" do
    category = Category.create!(name: "Sem lançamentos")
    assert_difference("Category.count", -1) do
      delete category_url(category)
    end

    assert_redirected_to categories_url
  end

  test "cannot destroy a category with entries" do
    assert_no_difference("Category.count") do
      delete category_url(@category)
    end

    assert_redirected_to categories_url
    follow_redirect!
    assert_select "[role=alert]", text: /lançamentos vinculados/
  end

  test "returns to the edit form after creating a category" do
    entry = entries(:one)
    get edit_entry_url(entry)
    assert_select "a[href='#{categories_path(from_entry: "1", entry_id: entry.id)}']"

    get categories_url, params: { from_entry: "1", entry_id: entry.id }
    assert_select "a[href='#{edit_entry_path(entry)}']", text: "Voltar para o formulário"

    post categories_url, params: { category: { name: "Nova categoria" } }
    assert_redirected_to categories_url
    follow_redirect!
    assert_select "a[href='#{edit_entry_path(entry)}']", text: "Voltar para o formulário"

    get category_url(Category.last)
    assert_select "a[href='#{edit_entry_path(entry)}']", text: "Voltar para o formulário"
  end

  test "returns to the edit form after a deletion is refused" do
    entry = entries(:one)
    get categories_url, params: { from_entry: "1", entry_id: entry.id }
    delete category_url(entry.category)
    follow_redirect!

    assert_select "[role=alert]"
    assert_select "a[href='#{edit_entry_path(entry)}']", text: "Voltar para o formulário"
  end

  test "new entry origin replaces the previous edit origin" do
    get categories_url, params: { from_entry: "1", entry_id: entries(:one).id }
    get categories_url, params: { from_entry: "1" }

    assert_select "a[href='#{new_entry_path}']", text: "Voltar para o formulário"
  end

  test "direct access and invalid entry origins return to new entry" do
    get categories_url
    assert_select "a[href='#{new_entry_path}']", text: "Voltar para o formulário"

    get categories_url, params: { from_entry: "1", entry_id: "https://example.com" }
    assert_select "a[href='#{new_entry_path}']", text: "Voltar para o formulário"
  end
end
