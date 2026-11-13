class EnforceUserOwnership < ActiveRecord::Migration[8.1]
  def change
    change_column_null :entries, :user_id, false
    change_column_null :categories, :user_id, false

    add_index :categories, [ :user_id, :name ], unique: true
  end
end
