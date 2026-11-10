categories = [
  "Alimentação",
  "Transporte",
  "Moradia",
  "Saúde",
  "Educação",
  "Lazer",
  "Compras"
]

categories.each do |name|
  Category.find_or_create_by!(name: name)
end
