class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  before_action :redirect_if_authenticated

  rate_limit to: 5, within: 3.minutes, only: :create,
    with: -> {
      redirect_to new_registration_path,
        alert: I18n.t("messages.registrations.too_many_attempts")
    }

  def new
    @user = User.new
    @registration_closed = User.count >= User::MAX_ACCOUNTS
  end

  def create
    @user = User.register(registration_params)

    if @user.persisted?
      start_new_session_for(@user)

      redirect_to root_path,
        notice: I18n.t("messages.registrations.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def registration_params
    params.expect(user: [
      :email_address,
      :password,
      :password_confirmation
    ])
  end

  def redirect_if_authenticated
    redirect_to root_path if authenticated?
  end
end
