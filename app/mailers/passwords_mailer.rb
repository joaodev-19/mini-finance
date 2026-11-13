class PasswordsMailer < ApplicationMailer
  default from: ENV.fetch(
    "MAIL_FROM",
    "Mini Finance <onboarding@resend.dev>"
  )

  def reset(user)
    @user = user
    mail subject: "Reset your password", to: user.email_address
  end
end
