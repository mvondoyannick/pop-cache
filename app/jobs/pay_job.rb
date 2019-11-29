class PayJob < ApplicationJob
  queue_as :default

  # send SMS en differé
  # @params [Integer] customer_phone
  # @params [Integer] merchant_phone
  # @params [FLoat] amount
  # @params [String] complete_name
  # @params [Float] solde
  # @params [String] hash
  # @params [Integer] id
  def perform(amount, phone, complete_name=nil, solde=nil, hash, id)
    @phone = phone
    @amount = amount
    @complete_name = complete_name
    @solde = solde
    @hash = hash
    @id = id

    #sending SMS like à job after 2 seconds
    if @complete_name.present?
      Sms.nexah(@phone, "Paiement d'un montant de #{@amount} F CFA, de #{@complete_name}. Solde :  #{@solde} F CFA. ID : #{@hash}. Plus sur https://payquick-develop.herokuapp.com/webview/#{@hash}/#{@id}")
    else
      Sms.nexah(@phone, "Paiement effectue depuis votre compte d'un montant de #{@amount} F CFA, Transaction de paiement Effectuee. Plus sur https://payquick-develop.herokuapp.com/webview/#{@hash}/#{@id}")
    end
    # Do something later
    # compteur = History.where(created_at: Date.today.beginning_of_day..Date.today.end_of_day).count
    # benefice = Commission.where(created_at: Date.today.beginning_of_day..Date.today.end_of_day).sum(:commission)
    # Sms.nexah(690376949, "#{compteur} Transaction(s) ont eu lieux entre #{Date.today.beginning_of_day} et #{Date.today.end_of_day}. Les bénéfices sont de : #{benefice.to_f} FCFA. PMQ report")
    puts "Done at #{Time.now}"
    return "SEND!"
  end

end
