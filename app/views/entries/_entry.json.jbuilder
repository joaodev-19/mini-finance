json.extract! entry, :id, :title, :amount, :occurred_on, :description, :created_at, :updated_at
json.url entry_url(entry, format: :json)
