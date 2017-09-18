class UpdateMailer < ApplicationMailer

  default from: "app76885431@heroku.com"

  def test_email(user, new_documents, new_hearings)
    @new_documents = new_documents
    @new_hearings = new_hearings
    mail(to: user.email, subject: "New Documents/Hearings Posted")
  end

end
