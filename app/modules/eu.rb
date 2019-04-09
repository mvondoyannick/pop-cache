#Module permettant de gerer les transactions Express Union
module Eu

  require 'faraday'
  require 'digest'

  $conn = Faraday.new(:url=> 'http://195.24.207.114:9000/eumobile_api/v2.1/?service=')
  $id = 53
  $pwd = 'AG05E0U4#'
  $currency = 'XAF'
  $date = Time.now
  $duedate = 5.minutes.from_now
  $key = 'abcd1234'

  class EuApi
    def initialize(amount, name, phone, custid, label)

      @amount   = amount
      @name     = name
      @phone    = phone
      @custid   = custid
      @label    = label
      @ref      = '123456789'
      @billno   = SecureRandom.hex(5)
      @hash     = Digest::MD5.hexdigest("#{$id}+#{$pwd}+#{@billno}+#{@amount}+#{$currency}+#{$date}+#{$duedate}+#{@name}+#{@phone}+_FYLO_+Paiement+#{$key}")

    end

    # permet d'envoyer les information de creer un compte vers l'API EUM
    def createEum

    end

    def self.getAccountBalance
      #demarrage de Faraday
      $conn.post do |req|
        req.url 'getAccountBalance'
        req.headers['Content-Type'] = 'application/json'
        req.body = { 
          Hash: "732599963acc63aec3754c74d779c98c",
          Id:53,
          Pwd: "AG05E0U4#"
          }
      end
    end

    #permet d'envoyer une requete de payement
    def self.pay(ref, phone, amount, name)
      @phone = phone
      @label = "Paiement"
      @ref = '123456789'
      @billno = SecureRandom.hex(5)
      @amount = amount
      @name = name
      @hash = Digest::MD5.hexdigest("#{$id}+#{$pwd}+#{@billno}+#{@amount}+#{$currency}+#{$date}+#{$duedate}+#{@name}+#{@phone}+_FYLO_+Paiement+#{$key}")
      $conn.post do |req|
        req.url 'sendPaymentRequest'
        req.body = {
          id: 53,
          pwd: 'AG05E0U4#',
          billno: @billno,
          amount: 250,
          currency: 'XAF',
          date: Time.now,
          duedate: 10.minutes.from_now,
          name: "MVONDO Yannick",
          custid: "_FYLO_",
          phone: 237691451189,
          hash: @hash
        }
      end
    end

    #permet de crediter un compte EUM via l'API EU
    def creditEum(phone, password, amount)

    end

    #permet de supprimer une compte EUM via l'API
    def deleteEum(phone, password)

    end

  end

  #classe pour la gestion des partenaires EU/EUM
  class EuPartner
    def initialize()

    end

    #creation d'un partenaire
    def createEuPartner(name, second_name, phone, cni)

    end
  end

end