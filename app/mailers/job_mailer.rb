class JobMailer < ApplicationMailer
  def send_csv(email, csv)
    attachments['my_file_name.csv'] = {mime_type: 'text/csv', content: csv}
    mail(to: email, subject: "Rapport CSV", body: "my body", timeout: 40000)
  end
end
