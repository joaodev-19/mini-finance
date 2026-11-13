class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: I18n.t("messages.passwords.too_many_attempts") }

  def new
  end

  def create
    if user = User.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(user).deliver_now
    end

    redirect_to new_session_path, notice: I18n.t("messages.passwords.instructions_sent")
  end

  def edit
  end

  def update
    if params[:password].blank? ||
      params[:password_confirmation].blank?

      redirect_to edit_password_path(params[:token]),
        alert: I18n.t("messages.passwords.required")

      return
    end

    if @user.update(
      params.permit(:password, :password_confirmation)
    )
      @user.sessions.destroy_all

      redirect_to new_session_path,
        notice: I18n.t("messages.passwords.updated")
    else
      redirect_to edit_password_path(params[:token]),
        alert: I18n.t("messages.passwords.not_updated", errors: @user.errors.full_messages.to_sentence)
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: I18n.t("messages.passwords.invalid_token")
    end
end
