class ChangeCategoriesToNullFalse < ActiveRecord::Migration[8.1]
  def change
    change_column_null :entries, :category_id, false
  end
end
