class ChangeEntriesAmountToNullFalse < ActiveRecord::Migration[8.1]
  def change
    change_column_null :entries, :amount, false
  end
end
