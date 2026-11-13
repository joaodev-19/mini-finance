User.find_each(&:ensure_default_categories!)

puts "Categorias-base preparadas para #{User.count} usuário(s)."