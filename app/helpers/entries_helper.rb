module EntriesHelper
  def entry_amount_class(entry)
    return "app-note-entry-amount--income" if entry.income?
    return "app-note-entry-amount--expense" if entry.expense?

    ""
  end
end
