# Preview all emails at http://localhost:3000/rails/mailers/api_mailer
class ApiMailerPreview < ActionMailer::Preview

  def notifyAdmin

    ApiMailer.notifyAdmin

  end

end
