module EntriesHelper
  ENTRY_KIND_LABELS = { "income" => "Receita", "expense" => "Despesa" }.freeze

  def entry_kind_label(entry)
    ENTRY_KIND_LABELS.fetch(entry.kind, "Não informado")
  end

  def entry_kind_options
    Entry.kinds.keys.map { |kind| [ ENTRY_KIND_LABELS.fetch(kind), kind ] }
  end

  def entry_amount_class(entry)
    return "app-note-entry-amount--income" if entry.income?
    return "app-note-entry-amount--expense" if entry.expense?

    ""
  end
end
