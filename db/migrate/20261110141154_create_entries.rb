class CreateEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :entries do |t|
      t.string :title
      t.decimal :amount
      t.date :occurred_on
      t.text :description

      t.timestamps
    end
  end
end
