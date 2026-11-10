class ChangeEntriesAmountPrecisionAndScale < ActiveRecord::Migration[8.1]
  def change
    change_column :entries, :amount, :decimal, precision: 12, scale: 2
  end
end
