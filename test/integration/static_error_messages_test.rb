require "test_helper"

class StaticErrorMessagesTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  test "static errors offer Portuguese guidance and a route back to the notebook" do
    %w[400.html 404.html 422.html 500.html 406-unsupported-browser.html].each do |file|
      html = Nokogiri::HTML(Rails.root.join("public", file).read)
      assert_equal "pt-BR", html.at_css("html")["lang"]
      assert_includes html.at_css("title").text, "Mini Finance"
      assert_equal "Voltar ao caderno", html.at_css("a[href='/']").text
      assert_nil html.at_css("#error-description")
      refute_includes html.at_css("article").text, "application owner"
    end
  end
end
