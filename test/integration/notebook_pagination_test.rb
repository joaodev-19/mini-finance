require "test_helper"

class NotebookPaginationIntegrationTest < ActionDispatch::IntegrationTest
  test "categories are ordered and split into distinct pages" do
    11.times { |number| Category.create!(name: "Divisória #{number.to_s.rjust(2, '0')}") }
    ordered_ids = Category.order(:name, :id).pluck(:id)

    get categories_path
    assert_response :success
    assert_equal ordered_ids.first(5), category_ids
    assert_select ".app-paper-label", text: "13 categorias"
    assert_select "nav[aria-label='Paginação de categorias']" do
      assert_select "[aria-current=page]", text: "1"
      assert_select "[aria-disabled=true][aria-label='Página anterior']"
      assert_select "a[rel=next]", count: 1
    end

    get categories_path, params: { page: 2 }
    assert_equal ordered_ids.slice(5, 5), category_ids
    assert_select ".app-notebook-pagination-summary", text: "6–10 de 13 categorias"

    get categories_path, params: { page: 999 }
    assert_equal ordered_ids.last(3), category_ids
    assert_select "[aria-disabled=true][aria-label='Próxima página']"
  end

  test "entries paginate deterministically after filtering and preserve filters in links" do
    11.times do |number|
      Entry.create!(title: "Anotação #{number}", amount: 10, occurred_on: Date.new(2026, 11, 12), kind: :expense, category: categories(:one))
    end
    scope = Entry.where(category: categories(:one), kind: :expense).order(occurred_on: :desc, id: :desc)
    ordered_ids = scope.pluck(:id)

    get entries_path, params: { category: categories(:one).id, kind: "expense", per_page: 3 }
    assert_response :success
    assert_equal ordered_ids.first(3), entry_ids
    assert_select ".app-notebook-entry-count", text: "#{ordered_ids.size} lançamentos"
    next_link = css_select(".app-notebook-pagination a[rel=next]").first["href"]
    assert_equal entries_path, URI.parse(next_link).path
    query = Rack::Utils.parse_query(URI.parse(next_link).query)
    assert_equal categories(:one).id.to_s, query["category"]
    assert_equal "expense", query["kind"]
    assert_equal "3", query["per_page"]
    assert_equal "2", query["page"]

    get next_link
    assert_equal ordered_ids.slice(3, 3), entry_ids
    assert_select "form.app-notebook-filters input[name=page]", count: 0
  end

  test "empty filtered entries retain a usable folio" do
    get entries_path, params: { category: "0", page: 999 }
    assert_response :success
    assert_select ".app-notebook-empty h3", text: "Nenhum lançamento encontrado"
    assert_select ".app-notebook-pagination-summary", text: "0–0 de 0 lançamentos"
    assert_select ".app-notebook-pagination a", count: 0
  end

  test "JSON indexes continue returning the complete collection" do
    get entries_path(format: :json), params: { per_page: 1 }
    assert_response :success
    assert_equal Entry.count, response.parsed_body.size

    get categories_path(format: :json), params: { per_page: 1 }
    assert_response :success
    assert_equal Category.count, response.parsed_body.size
  end

  private

    def category_ids
      css_select("#categories article").map { |element| element["id"].delete_prefix("category_").to_i }
    end

    def entry_ids
      css_select("#entries article").map { |element| element["id"].delete_prefix("entry_").to_i }
    end
end
