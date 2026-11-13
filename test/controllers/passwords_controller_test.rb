require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  self.fixture_table_names = [ "users" ]
  setup { @user = User.take }

  test "new" do
    get new_password_path
    assert_response :success
  end

  test "create" do
    assert_emails 1 do
      post passwords_path, params: { email_address: @user.email_address }
    end
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "Se houver uma conta com esse e-mail"
  end

  test "create for an unknown user redirects but sends no mail" do
    assert_emails 0 do
      post passwords_path, params: { email_address: "missing-user@example.com" }
    end
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "Se houver uma conta com esse e-mail"
  end

  test "edit" do
    get edit_password_path(@user.password_reset_token)
    assert_response :success
  end

  test "edit with invalid password reset token" do
    get edit_password_path("invalid token")
    assert_redirected_to new_password_path

    follow_redirect!
    assert_alert "Este link de recuperação é inválido ou expirou."
  end

  test "update" do
    assert_changes -> { @user.reload.password_digest } do
      put password_path(@user.password_reset_token), params: { password: "nova-senha-segura", password_confirmation: "nova-senha-segura" }
      assert_redirected_to new_session_path
    end

    follow_redirect!
    assert_notice "Senha atualizada com sucesso."
  end

  test "update with non matching passwords" do
    token = @user.password_reset_token
    assert_no_changes -> { @user.reload.password_digest } do
      put password_path(token), params: { password: "nova-senha-segura", password_confirmation: "outra-senha-segura" }
      assert_redirected_to edit_password_path(token)
    end

    follow_redirect!
    assert_alert "Confirmação da senha não confere com a senha informada"
  end

  test "short passwords report their real validation instead of a confirmation mismatch" do
    token = @user.password_reset_token
    assert_no_changes -> { @user.reload.password_digest } do
      put password_path(token), params: { password: "curta", password_confirmation: "curta" }
    end
    follow_redirect!
    assert_alert "Senha deve ter pelo menos 8 caracteres"
    refute_includes response.body, "não confere"
  end

  test "blank passwords and missing confirmation do not report success or revoke sessions" do
    @user.sessions.create!
    [ { password: "", password_confirmation: "" }, { password: "nova-senha-segura" } ].each do |attributes|
      token = @user.password_reset_token
      count = @user.sessions.count
      assert_no_changes -> { @user.reload.password_digest } do
        put password_path(token), params: attributes
      end
      assert_redirected_to edit_password_path(token)
      assert_equal count, @user.sessions.count
      assert User.find_by_password_reset_token(token)
      follow_redirect!
      assert_alert "Preencha a nova senha e a confirmação para continuar."
      assert_select "[role=status]", count: 0
    end
  end

  test "expired recovery links explain how to request a new one" do
    token = @user.password_reset_token
    travel 16.minutes do
      get edit_password_path(token)
      assert_redirected_to new_password_path
      follow_redirect!
      assert_alert "Solicite um novo link para continuar."
    end
  end

  test "password email has Portuguese subject HTML text and expiration instructions" do
    email = PasswordsMailer.reset(@user).message
    assert_equal "Crie uma nova senha para o Mini Finance", email.subject
    [ email.text_part.decoded, email.html_part.decoded ].each do |body|
      assert_includes body, "Este link expira em 15 minutos."
      assert_includes body, "Se você não fez esta solicitação, ignore este e-mail."
      refute_includes body, "You can reset"
    end
  end

  private
    def assert_notice(text)
      assert_select "[role=status]", /#{Regexp.escape(text)}/
    end

    def assert_alert(text)
      assert_select "[role=alert]", /#{Regexp.escape(text)}/
    end
end
