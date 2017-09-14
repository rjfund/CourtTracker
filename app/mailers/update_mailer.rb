class UpdateMailer < ApplicationMailer

  default from: "app76885431@heroku.com"

  def test_email(new_documents)
    @new_documents = new_documents
    mail(to: "coopermayne@gmail.com", subject: "heyhey")
  end

end
