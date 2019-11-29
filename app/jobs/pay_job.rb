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
  def perform(amount, phone, type, complete_name=nil, solde=nil, hash, id, frais=nil, total_preleve=nil)
    @phone = phone
    @amount = amount
    @type = type
    @complete_name = complete_name
    @solde = solde
    @hash = hash
    @id = id
    @frais = frais
    @total_preleve = total_preleve

    #sending SMS like à job after 2 seconds
    case type
    when "merchant"
      Sms.nexah(@phone, "Paiement d'un montant de #{@amount} FCFA recu de Mr/Mme #{@complete_name}. Votre Solde est actuellement de :  #{@solde} F CFA. ID Transaction : #{@hash}. Plus sur d'informations sur https://payquick-develop.herokuapp.com/webview/#{@hash}/#{@id}")
    when "payer"
      Sms.nexah(@phone, "Paiement de #{@amount} F CFA dont les frais s'élève à #{@frais} FCFA. Le montant total prélevé de votre compte est de #{total_preleve} FCFA. Plus sur https://payquick-develop.herokuapp.com/webview/#{@hash}/#{@id}")
    else
      # sending errors to admins
      return false, "Type de paiement inconnu"
    end
    # Do something later
    # compteur = History.where(created_at: Date.today.beginning_of_day..Date.today.end_of_day).count
    # benefice = Commission.where(created_at: Date.today.beginning_of_day..Date.today.end_of_day).sum(:commission)
    # Sms.nexah(690376949, "#{compteur} Transaction(s) ont eu lieux entre #{Date.today.beginning_of_day} et #{Date.today.end_of_day}. Les bénéfices sont de : #{benefice.to_f} FCFA. PMQ report")
  end

end
