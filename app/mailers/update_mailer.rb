class UpdateMailer < ApplicationMailer

  default from: "app76885431@heroku.com"

  def test_email(change_count)
    @change_count = change_count
    mail(to: "coopermayne@gmail.com", subject: "heyhey")
  end

end
