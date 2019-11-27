class PayJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    compteur = History.where(created_at: Date.today.beginning_of_day..Date.today.end_of_day).count
    Sms.nexah(697335061, "#{compteur} Transaction on eu lieux entre #{Date.today.beginning_of_day} et #{Date.today.end_of_day}. PMQ report")
    sleep 2
    puts "Done at #{Time.now}"
  end
end
