require "test_helper"

class AuthenticationViewsTest < ActionDispatch::IntegrationTest
  # Account UI does not need financial fixtures that are being migrated to ownership.
  self.fixture_table_names = ["users"]

  test "public account pages connect sign in registration and password recovery" do
    [new_session_path, new_registration_path, new_password_path].each do |path|
      get path
      assert_response :success
      assert_select "main", count: 1
      assert_select "label[for]", minimum: 1
      assert_select "nav[aria-label='Acesso ao caderno']" do
        assert_select "a[href='#{new_session_path}']"
        assert_select "a[href='#{new_registration_path}']"
      end
      assert_select "form.app-notebook-account", count: 0
    end
    get new_session_path
    assert_select "form[action='#{session_path}'][method=post]" do
      assert_select "input[name=email_address][autocomplete=username]"
      assert_select "input[name=password][autocomplete=current-password]"
    end
    assert_select "a[href='#{new_password_path}']"
    get new_registration_path
    assert_select "input[name='user[email_address]']"
    assert_select "input[name='user[password_confirmation]']"
    assert_select "main a[href='#{new_registration_path}']", count: 0
  end

  test "password renewal preserves token method and accessible fields" do
    token = users(:one).password_reset_token
    get edit_password_path(token)
    assert_response :success
    assert_select "form[action='#{password_path(token)}'][method=post]" do
      assert_select "input[name=_method][value=put]"
      assert_select "input[name=password][autocomplete=new-password]"
      assert_select "input[name=password_confirmation][autocomplete=new-password]"
    end
  end

  test "signed in users can sign out through the shared notebook bookmark" do
    sign_in_as(users(:one))
    get new_password_path
    assert_response :success
    assert_select "form.app-notebook-account[action='#{session_path}'][method=post]" do
      assert_select "input[name=_method][value=delete]"
      assert_select "button", text: /Sair/
    end
    assert_select "nav[aria-label='Seções do caderno'] a", count: 3
    assert_difference("Session.count", -1) { delete session_path }
    assert_redirected_to new_session_path
    follow_redirect!
    assert_select "form.app-notebook-account", count: 0
    assert_select "nav[aria-label='Acesso ao caderno']"
  end
end
