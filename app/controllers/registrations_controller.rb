class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  before_action :redirect_if_authenticated

  rate_limit to: 5, within: 3.minutes, only: :create,
    with: -> {
      redirect_to new_registration_path,
        alert: "Muitas tentativas. Aguarde alguns minutos."
    }

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      start_new_session_for(@user)

      redirect_to root_path,
        notice: "Sua conta foi criada com sucesso!"
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
