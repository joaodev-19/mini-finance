require "test_helper"

class EntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @entry = entries(:one)
  end

  test "should get index" do
    get entries_url
    assert_response :success
  end

  test "should get new" do
    get new_entry_url
    assert_response :success
  end

  test "should create entry" do
    assert_difference("Entry.count") do
      post entries_url, params: { entry: { amount: @entry.amount, description: "Detalhes do lançamento", occurred_on: @entry.occurred_on, title: @entry.title, category_id: @entry.category_id, kind: "expense" } }
    end

    assert_redirected_to entry_url(Entry.last)
    assert_equal "expense", Entry.last.kind
    assert_equal "Detalhes do lançamento", Entry.last.description
  end

  test "should show entry" do
    get entry_url(@entry)
    assert_response :success
  end

  test "should get edit" do
    get edit_entry_url(@entry)
    assert_response :success
  end

  test "should update entry" do
    patch entry_url(@entry), params: { entry: { amount: @entry.amount, description: "Descrição atualizada", occurred_on: @entry.occurred_on, title: @entry.title, category_id: @entry.category_id, kind: "expense" } }
    assert_redirected_to entry_url(@entry)
    assert_equal "expense", @entry.reload.kind
    assert_equal "Descrição atualizada", @entry.description
  end

  test "index shows the kind and amount class for each entry" do
    get entries_url

    assert_select "##{ActionView::RecordIdentifier.dom_id(entries(:one))}" do
      assert_select ".app-note-entry-kind", "Receita"
      assert_select ".app-note-entry-amount--income", text: /\+.*R\$/
    end
    assert_select "##{ActionView::RecordIdentifier.dom_id(entries(:two))}" do
      assert_select ".app-note-entry-kind", "Despesa"
      assert_select ".app-note-entry-amount--expense", text: /-.*R\$/
    end
  end

  test "form provides description and the model kind options" do
    get new_entry_url

    assert_select "textarea[name='entry[description]']"
    assert_select "select[name='entry[kind]'][required]" do
      assert_select "option[value=income]", "Receita"
      assert_select "option[value=expense]", "Despesa"
    end
    assert_select "input[name='entry[amount]'][min='0.01']"
  end

  test "show displays details and escapes description markup" do
    @entry.update!(description: "Primeira linha\n<script>alert(1)</script>")
    get entry_url(@entry)

    assert_select "dt", text: "Tipo do lançamento"
    assert_select "dd", text: "Receita"
    assert_select "time[datetime='#{@entry.occurred_on.iso8601}']", @entry.occurred_on.strftime("%d/%m/%Y")
    assert_select ".app-notebook-description" do |elements|
      assert_equal @entry.description, elements.first.text
    end
    assert_select ".app-notebook-description script", count: 0
    assert_select ".app-note-entry-amount--income"
  end

  test "show handles entries without kind or description" do
    @entry.update_columns(kind: nil, description: "")
    get entry_url(@entry)

    assert_response :success
    assert_select "dd", text: "Não informado"
    assert_select ".app-notebook-description", "Sem descrição."
    assert_select ".app-note-entry-amount--income, .app-note-entry-amount--expense", count: 0
  end

  test "invalid submission retains description and shows errors" do
    post entries_url, params: { entry: { title: "", amount: "0", category_id: @entry.category_id, kind: "expense", occurred_on: @entry.occurred_on, description: "Detalhes preservados" } }

    assert_response :unprocessable_content
    assert_select "[role=alert]"
    assert_select "textarea[name='entry[description]']", "Detalhes preservados"
    assert_select "select[name='entry[kind]'] option[selected][value=expense]"
  end

  test "should destroy entry" do
    assert_difference("Entry.count", -1) do
      delete entry_url(@entry)
    end

    assert_redirected_to entries_url
  end
end
