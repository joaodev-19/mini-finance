require "test_helper"

class TranslatedValidationTest < ActiveSupport::TestCase
  self.fixture_table_names = [ "users" ]

  test "account validation names the email password and confirmation in Portuguese" do
    user = User.new(email_address: users(:one).email_address, password: "curta", password_confirmation: "diferente")
    assert_not user.valid?
    assert_includes user.errors.full_messages, "E-mail já está cadastrado"
    assert_includes user.errors.full_messages, "Senha deve ter pelo menos 8 caracteres"
    assert_includes user.errors.full_messages, "Confirmação da senha não confere com a senha informada"
  end

  test "entry validation names financial fields and explains a missing category" do
    entry = Entry.new(user: users(:one), amount: 0)
    assert_not entry.valid?
    assert_includes entry.errors.full_messages, "Título não pode ficar em branco"
    assert_includes entry.errors.full_messages, "Data do lançamento não pode ficar em branco"
    assert_includes entry.errors.full_messages, "Tipo do lançamento não pode ficar em branco"
    assert_includes entry.errors.full_messages, "Valor deve ser maior que 0"
    assert_includes entry.errors.full_messages, "Categoria deve ser selecionada"
  end

  test "duplicate category message makes the account scope clear" do
    user = users(:one)
    user.categories.create!(name: "Teste de tradução")
    duplicate = user.categories.new(name: "Teste de tradução")
    assert_not duplicate.valid?
    assert_includes duplicate.errors.full_messages, "Nome da categoria já está em uso nesta conta"
  end

  test "account cap keeps the existing limit and explains why registration is unavailable" do
    (User::MAX_ACCOUNTS - User.count).times do |index|
      User.create!(email_address: "limite-#{index}@example.test", password: "senha-segura")
    end
    user = User.new(email_address: "sem-vaga@example.test", password: "senha-segura")
    assert_not user.valid?
    assert_includes user.errors.full_messages, "O limite de #{User::MAX_ACCOUNTS} contas foi atingido. Não é possível criar outra conta no momento."
  end

  test "a category with entries explains the deletion restriction without technical terms" do
    user = users(:one)
    category = user.categories.create!(name: "Categoria vinculada")
    user.entries.create!(category: category, title: "Teste", amount: 10, kind: :expense, occurred_on: Date.current)
    assert_not category.destroy
    assert_includes category.errors.full_messages, "Não é possível excluir esta categoria enquanto houver lançamentos vinculados"
    assert Category.exists?(category.id)
  end
end
