require "test_helper"

class NotebookPaginationIntegrationTest < ActionDispatch::IntegrationTest
  test "categories are ordered and split into distinct pages" do
    11.times { |number| Category.create!(name: "Divisória #{number.to_s.rjust(2, '0')}") }
    ordered_ids = Category.order(:name, :id).pluck(:id)

    get categories_path
    assert_response :success
    assert_equal ordered_ids.first(10), category_ids
    assert_select ".app-paper-label", text: "13 categorias"
    assert_select "nav[aria-label='Paginação de categorias']" do
      assert_select "[aria-current=page]", text: "1"
      assert_select "[aria-disabled=true][aria-label='Página anterior']"
      assert_select "a[rel=next]", count: 1
    end

    get categories_path, params: { page: 2 }
    assert_equal ordered_ids.last(3), category_ids
    assert_select ".app-notebook-pagination-summary", text: "11–13 de 13 categorias"

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

  test "search persists with the other filters through pages and page size changes" do
    12.times do |number|
      Entry.create!(title: "Consulta móvel #{number}", amount: 10, occurred_on: Date.current, kind: :expense, category: categories(:one))
    end
    filters = { search: "Consulta móvel", category: categories(:one).id.to_s, kind: "expense" }
    get entries_path, params: filters.merge(per_page: 10, arbitrary: "ignored")
    assert_equal 10, entry_ids.size
    assert_select "summary", text: /Filtros \(3\)/
    assert_select "input[name=search][value='Consulta móvel']"
    ids = css_select("main [id]").map { |element| element["id"] }
    assert_equal ids.uniq, ids
    next_link = css_select(".app-notebook-pagination a[rel=next]").first["href"]
    query = Rack::Utils.parse_query(URI.parse(next_link).query)
    assert_equal filters.merge("per_page" => "10", "page" => "2").stringify_keys, query
    get next_link
    assert_equal 2, entry_ids.size
    assert_select ".app-notebook-pagination-summary", text: "11–12 de 12 lançamentos"
    assert_select "form.app-notebook-page-size" do
      assert_select "input[name=search][value='Consulta móvel']"
      assert_select "input[name=page]", count: 0
      assert_select "details.app-notebook-page-size-picker" do
        assert_select "input[type=radio][name=per_page][value='10'][checked]"
        assert_select "input[type=radio][name=per_page][value='20']"
      end
    end
    get entries_path, params: filters.merge(per_page: 20)
    assert_equal 12, entry_ids.size
    assert_select "[aria-current=page]", text: "1"
  end

  test "text only search has a filtered empty state and counts as an active filter" do
    get entries_path, params: { search: "Não existe neste caderno" }
    assert_select "summary", text: /Filtros \(1\)/
    assert_select ".app-notebook-empty h3", text: "Nenhum lançamento encontrado"
    assert_select ".app-notebook-empty a[href='#{entries_path}']", text: "Limpar filtros"
    assert_select "input[name=search][value='Não existe neste caderno']"
  end

  test "category pagination ignores entry filters and deleting a last page remains usable" do
    category = Category.create!(name: "ZZZ última categoria")
    get categories_path, params: { per_page: 1, page: 3, search: "ignore", kind: "expense" }
    next_or_previous = css_select(".app-notebook-pagination a[rel=prev]").first["href"]
    assert_equal %w[page per_page], Rack::Utils.parse_query(URI.parse(next_or_previous).query).keys.sort
    delete category_path(category), params: { page: 3, per_page: 1 }
    assert_redirected_to categories_path(page: 3, per_page: 1)
    follow_redirect!
    assert_select ".app-notebook-pagination-summary", text: "2–2 de 2 categorias"
    assert_select ".app-notebook-page-current", text: "2"
  end

  test "entry detail and deletion retain the filtered list context" do
    entry = Entry.create!(title: "Consulta móvel", amount: 10, occurred_on: Date.current, kind: :expense, category: categories(:one))
    filters = { search: "Consulta móvel", category: categories(:one).id.to_s, kind: "expense", per_page: "10", page: "1" }
    get entries_path, params: filters
    assert_select "a[href='#{entry_path(entry, filters)}']"
    get entry_path(entry), params: filters
    assert_select "form[action='#{entry_path(entry, filters)}']"
    delete entry_path(entry), params: filters
    assert_redirected_to entries_path(filters)
    follow_redirect!
    assert_select ".app-notebook-pagination-summary", text: "0–0 de 0 lançamentos"
  end

  test "JSON indexes continue returning the complete collection" do
    get entries_path(format: :json), params: { per_page: 1 }
    assert_response :success
    assert_equal Entry.count, response.parsed_body.size

    get categories_path(format: :json), params: { per_page: 1 }
    assert_response :success
    assert_equal Category.count, response.parsed_body.size
  end

  test "category form creates and edits a unique category and keeps validation feedback" do
    get new_category_path
    assert_select "input[name='category[name]'][required]"
    assert_difference("Category.count", 1) do
      post categories_path, params: { category: { name: "Categoria móvel" } }
    end
    category = Category.find_by!(name: "Categoria móvel")
    assert_redirected_to categories_path
    follow_redirect!
    assert_select "[role=status]", text: /criada com sucesso/
    patch category_path(category), params: { category: { name: "Categoria móvel revisada" } }
    assert_redirected_to category_path(category)
    assert_equal "Categoria móvel revisada", category.reload.name
    patch category_path(category), params: { category: { name: "" } }
    assert_response :unprocessable_content
    assert_select "[role=alert]"
    assert_equal "Categoria móvel revisada", category.reload.name
  end

  private

    def category_ids
      css_select("#categories article").map { |element| element["id"].delete_prefix("category_").to_i }
    end

    def entry_ids
      css_select("#entries article").map { |element| element["id"].delete_prefix("entry_").to_i }
    end
end
