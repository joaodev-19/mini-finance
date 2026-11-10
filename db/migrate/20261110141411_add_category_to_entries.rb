class AddCategoryToEntries < ActiveRecord::Migration[8.1]
  def change
    add_reference :entries, :category, null: false, foreign_key: true
  end
end
