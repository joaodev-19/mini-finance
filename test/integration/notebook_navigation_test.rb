require "test_helper"

class NotebookNavigationTest < ActionDispatch::IntegrationTest
  test "entry pages keep the entries divider active" do
    entry = entries(:one)
    [root_path, entries_path, new_entry_path, entry_path(entry), edit_entry_path(entry)].each do |path|
      get path
      assert_response :success
      assert_notebook_navigation(entries_path)
    end
  end

  test "category pages keep the categories divider active" do
    category = categories(:one)
    [categories_path, new_category_path, category_path(category), edit_category_path(category)].each do |path|
      get path
      assert_response :success
      assert_notebook_navigation(categories_path)
    end
  end

  private

  def assert_notebook_navigation(active_path)
    assert_select ".app-notebook-shell", count: 1
    assert_select ".app-notebook-shell > nav.app-notebook-tabs", count: 1
    assert_select ".app-notebook-shell > .app-notebook-sheet", count: 1
    assert_select "nav.app-notebook-tabs[aria-label='Seções do caderno']", count: 1 do
      assert_select "a[aria-current='page']", count: 1
      assert_select "a[aria-current='page'][href='#{active_path}']"
      assert_select "a[href='#{entries_path}']", text: "Lançamentos"
      assert_select "a[href='#{categories_path}']", text: "Categorias"
      assert_select "a[href='#{dashboard_index_path}']", text: "Painel de Controle"
      assert_select "a", count: 3
    end
  end
end
