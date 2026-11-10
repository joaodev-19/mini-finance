class AddKindToEntries < ActiveRecord::Migration[8.1]
  def change
    add_column :entries, :kind, :string
  end
end
