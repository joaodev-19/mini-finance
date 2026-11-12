require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get dashboard_index_url
    assert_response :success
  end

  test "first leaf groups the summary and comparison" do
    get dashboard_index_url, params: { month: "2026-11" }

    assert_response :success
    assert_select ".app-dashboard-summary", count: 1
    assert_select ".app-dashboard-consumption", count: 1
    assert_select ".app-dashboard-comparison", count: 1
    assert_select ".app-dashboard-distribution", count: 0
    assert_select "nav[aria-label='Páginas do painel']" do
      assert_select "[aria-current=page]", text: /Balanço do mês/
      assert_select "a[rel=next][href='#{dashboard_index_path(month: "2026-11", page: 2)}']", text: /Mapa das despesas/
      assert_select ".app-dashboard-folio-position", text: "Folha 1 de 2"
    end
  end

  test "second leaf shows only the distribution and preserves its month on return" do
    get dashboard_index_url, params: { month: "2026-11", page: 2 }

    assert_response :success
    assert_select ".app-dashboard-summary, .app-dashboard-comparison", count: 0
    assert_select ".app-dashboard-distribution", count: 1
    assert_select "title", text: "Gastos por categoria | Mini Finance"
    assert_select ".app-dashboard-highlighter", count: 1
    assert_select "nav[aria-label='Páginas do painel']" do
      assert_select "[aria-current=page]", text: /Mapa das despesas/
      assert_select "a[rel=prev][href='#{dashboard_index_path(month: "2026-11", page: 1)}']", text: /Balanço do mês/
      assert_select ".app-dashboard-folio-position", text: "Folha 2 de 2"
    end

    get dashboard_index_path(month: "2026-11", page: 1)
    assert_select ".app-dashboard-month[datetime='2026-11']"
    assert_select ".app-dashboard-summary", count: 1
  end

  test "month navigation preserves the selected leaf" do
    [ 1, 2 ].each do |page|
      get dashboard_index_url, params: { month: "2026-12", page: page }

      assert_select ".app-dashboard-calendar" do
        assert_select "a[rel=prev][href='#{dashboard_index_path(month: "2026-11", page: page)}']"
        assert_select "a[rel=next][href='#{dashboard_index_path(month: "2027-01", page: page)}']"
      end
    end
  end

  test "empty distribution still allows returning to the first leaf" do
    get dashboard_index_url, params: { month: "2020-01", page: 2 }

    assert_response :success
    assert_select ".app-dashboard-empty", count: 1
    assert_select "meter", count: 0
    assert_select ".app-dashboard-folio a[rel=prev][href='#{dashboard_index_path(month: "2020-01", page: 1)}']"
  end

  test "unknown leaf falls back to the summary" do
    [ "0", "3", "invalid" ].each do |page|
      get dashboard_index_url, params: { page: page }

      assert_response :success
      assert_select ".app-dashboard-summary", count: 1
      assert_select ".app-dashboard-distribution", count: 0
      assert_select ".app-dashboard-folio-position", text: "Folha 1 de 2"
    end
  end

  test "income use summarizes percentages without repeating monthly amounts" do
    get dashboard_index_url, params: { month: "2026-11" }

    assert_select ".app-dashboard-consumption" do
      assert_select ".app-dashboard-consumption-percentage", text: "100,0%"
      assert_select "meter" do |meters|
        assert_equal 100, BigDecimal(meters.first["value"])
      end
      assert_select ".app-dashboard-consumption-note strong", text: "0,0%"
      assert_select "dl, .app-dashboard-consumption-balance", count: 0
    end
    refute_match(/R\$/, css_select(".app-dashboard-consumption").first.text)
    ids = css_select("main [id]").map { |element| element["id"] }
    assert_equal ids.uniq, ids
  end

  test "overspending preserves the real percentage above the meter limit" do
    entries(:two).update!(amount: "19.98")
    get dashboard_index_url, params: { month: "2026-11" }

    assert_select ".app-dashboard-consumption--overdrawn" do
      assert_select ".app-dashboard-consumption-percentage", text: "200,0%"
      assert_select ".app-dashboard-consumption-readout span", text: "Despesas acima das receitas"
      assert_select "meter" do |meters|
        assert_equal 100, BigDecimal(meters.first["value"])
        assert_match "200,0%", meters.first["aria-valuetext"]
      end
      assert_select ".app-dashboard-consumption-note strong", text: "-100,0%"
    end
  end

  test "expenses without income have no invented percentage" do
    entries(:one).destroy!
    get dashboard_index_url, params: { month: "2026-11" }

    assert_select ".app-dashboard-consumption" do
      assert_select "meter, .app-dashboard-consumption-percentage", count: 0
      assert_select ".app-dashboard-consumption-empty", text: /Sem receitas para comparar/
      assert_select ".app-dashboard-consumption-note", count: 0
    end
  end

  test "income without expenses shows zero use and an empty month has no ratio" do
    entries(:two).destroy!
    get dashboard_index_url, params: { month: "2026-11" }
    assert_select ".app-dashboard-consumption-percentage", text: "0,0%"
    assert_select ".app-dashboard-consumption meter" do |meters|
      assert_equal 0, BigDecimal(meters.first["value"])
    end
    assert_select ".app-dashboard-consumption-note strong", text: "100,0%"

    get dashboard_index_url, params: { month: "2020-01" }
    assert_select ".app-dashboard-consumption" do
      assert_select "meter, .app-dashboard-consumption-percentage", count: 0
      assert_select ".app-dashboard-consumption-empty", text: /Sem movimentação neste mês/
      assert_select ".app-dashboard-consumption-note", count: 0
    end
  end
end
