categories = [
  "Alimentação",
  "Transporte",
  "Moradia",
  "Saúde",
  "Educação",
  "Lazer",
  "Compras",
  "Trabalho",
  "Rendimentos"
]

categories.each do |name|
  user.categories.find_or_create_by!(name: name)
end

puts "Categorias preparadas: #{Category.count}"