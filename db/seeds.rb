
# db/seeds.rb

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
  Category.find_or_create_by!(name: name)
end

puts "Categorias preparadas: #{Category.count}"

# Dados fictícios apenas em desenvolvimento, salvo autorização explícita.
if Rails.env.development? || ENV["MINI_FINANCE_DEMO_SEED"] == "1"
  rng = Random.new(20261112)
  created = 0

  seed_entry = lambda do |key:, title:, category:, kind:, cents:, date:|
    marker = "[mini-finance-demo-v1:#{key}]"

    entry = Entry.find_or_create_by!(description: marker) do |record|
      record.title = title
      record.category = Category.find_by!(name: category)
      record.kind = kind
      record.amount = BigDecimal(cents.to_s) / 100
      record.occurred_on = date
    end

    created += 1 if entry.previously_new_record?
  end

  # [Título, Categoria, valor mínimo em centavos,
  #  valor máximo em centavos, dia do mês]
  fixed_expenses = [
    ["Aluguel", "Moradia", 110000, 180000, 5],
    ["Energia elétrica", "Moradia", 12000, 35000, 10],
    ["Água", "Moradia", 5000, 13000, 12],
    ["Internet residencial", "Moradia", 9000, 15000, 8],
    ["Plano de celular", "Moradia", 4000, 10000, 15],
    ["Supermercado", "Alimentação", 25000, 55000, 6],
    ["Supermercado do mês", "Alimentação", 20000, 48000, 20],
    ["Combustível", "Transporte", 12000, 30000, 9],
    ["Academia", "Saúde", 9000, 18000, 7],
    ["Farmácia", "Saúde", 3000, 12000, 18],
    ["Curso online", "Educação", 4000, 18000, 14],
    ["Streaming", "Lazer", 2500, 6500, 16],
    ["Cinema", "Lazer", 3000, 10000, 23],
    ["Compras pessoais", "Compras", 8000, 35000, 25],
    ["Restaurante", "Alimentação", 4000, 16000, 27]
  ]

  variable_expenses = [
    ["Café da manhã", "Alimentação", 1200, 3500],
    ["Almoço", "Alimentação", 2000, 6500],
    ["Lanche", "Alimentação", 1500, 4500],
    ["Delivery", "Alimentação", 3500, 11000],
    ["Mercado", "Alimentação", 2500, 17000],
    ["Padaria", "Alimentação", 1000, 4500],
    ["Uber", "Transporte", 1200, 4500],
    ["Ônibus", "Transporte", 500, 1500],
    ["Estacionamento", "Transporte", 500, 2500],
    ["Remédios", "Saúde", 1500, 8500],
    ["Consulta médica", "Saúde", 10000, 30000],
    ["Livros", "Educação", 3000, 16000],
    ["Material de estudo", "Educação", 2000, 9000],
    ["Jogo digital", "Lazer", 1500, 15000],
    ["Passeio", "Lazer", 2500, 16000],
    ["Cinema e pipoca", "Lazer", 3500, 9000],
    ["Roupas", "Compras", 6000, 25000],
    ["Acessórios", "Compras", 2000, 14000],
    ["Presente", "Compras", 3000, 18000],
    ["Itens para casa", "Moradia", 2500, 15000]
  ]

  # Gera lançamentos para o mês atual e os 14 anteriores.
  0.upto(14) do |months_ago|
    month = Date.current.beginning_of_month.prev_month(months_ago)
    month_key = month.strftime("%Y-%m")

    # Um mês completamente vazio.
    next if months_ago == 9

    last_day = month.end_of_month.day

    if months_ago.zero?
      last_day = [last_day, Date.current.day].min
    end

    # RECEITAS
    # Um mês sem receitas, para exercitar variações e saldos.
    unless months_ago == 4
      if last_day >= 5
        seed_entry.call(
          key: "#{month_key}:salary",
          title: "Salário mensal",
          category: "Trabalho",
          kind: "income",
          cents: rng.rand(320000..520000),
          date: month.change(day: 5)
        )
      end

      if months_ago % 3 == 0 && last_day >= 12
        seed_entry.call(
          key: "#{month_key}:freelance",
          title: "Projeto freelance",
          category: "Trabalho",
          kind: "income",
          cents: rng.rand(40000..180000),
          date: month.change(day: 12)
        )
      end

      if months_ago % 4 == 0 && last_day >= 10
        seed_entry.call(
          key: "#{month_key}:yield",
          title: "Rendimento financeiro",
          category: "Rendimentos",
          kind: "income",
          cents: rng.rand(1500..12000),
          date: month.change(day: 10)
        )
      end
    end

    # Um mês sem despesas, para exercitar o gráfico vazio.
    next if months_ago == 7

    # DESPESAS FIXAS
    fixed_expenses.each_with_index do |item, index|
      title, category, min_cents, max_cents, day = item

      date = month.change(day: [day, month.end_of_month.day].min)

      # Não gera despesas futuras no mês atual.
      next if date > Date.current

      seed_entry.call(
        key: "#{month_key}:fixed:#{index}",
        title: title,
        category: category,
        kind: "expense",
        cents: rng.rand(min_cents..max_cents),
        date: date
      )
    end

    # DESPESAS VARIÁVEIS
    rng.rand(12..22).times do |index|
      title, category, min_cents, max_cents = variable_expenses.sample(random: rng)

      date = month.change(day: rng.rand(1..last_day))

      seed_entry.call(
        key: "#{month_key}:variable:#{index}",
        title: title,
        category: category,
        kind: "expense",
        cents: rng.rand(min_cents..max_cents),
        date: date
      )
    end
  end

  puts "Novos lançamentos fictícios: #{created}"
  puts "Total de lançamentos no banco: #{Entry.count}"
  puts "Período fictício: últimos 15 meses"
else
  puts "Lançamentos fictícios ignorados fora do ambiente de desenvolvimento."
end