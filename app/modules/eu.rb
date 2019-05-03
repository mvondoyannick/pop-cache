#Module permettant de gerer les transactions Express Union
module Eu

  require 'faraday'
  require 'digest'

  $base_url         = "http://195.24.207.114:9000/eumobile_api/v2.1.1/?service=getAccountBalance"
  $payment_request  = "http://195.24.207.114:9000/eumobile_api/v2.1.1/?service=sendPaymentRequest"
  $payment_status   = "http://195.24.207.114:9000/eumobile_api/v2.1.1/?service=getPaymentStatus"
  $cashin           = "http://195.24.207.114:9000/eumobile_api/v2.1.1/?service=cashin"

  $conn = Faraday.new(:url=> 'http://195.24.207.114:9000/eumobile_api/v2.1/?service=')
  $id = 53
  $p = 'AG05E0U4#'
  $currency = 'XAF'
  $k = 'abcd1234'

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

    #Permet de tester un certain nombre de chose
    # @param [Object] hash
    # @param [Object] id
    # @param [Object] pwd
    def self.textEuApi(hash, id, pwd)
      @hash     = hash  #732599963acc63aec3754c74d779c98c
      @id       = id    #53
      @pwd      = pwd   #AG05E0U4#
    end

    # permet d'envoyer les information de creer un compte vers l'API EUM
    def self.createEum

      HTTParty.post($base_url,
        body: {
            hash: "04a15306f62d7399252ee90d525fe5e7",
            id:   53,
            pwd:  "AG05E0U4#"
        },
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' } )
    end

    #Obtiention du solde du compte
    def self.getAccountBalance
      #demarrage de Faraday
      $conn.post do |req|
        req.url 'getAccountBalance'
        req.headers['Content-Type'] = 'application/json'
        req.body = { 
          hash: "04a15306f62d7399252ee90d525fe5e7",
          id:   53,
          pwd:  "AG05E0U4#"
          }
      end
    end


    #Envoi d'une requet de paiement EU 
    # @param [Object] amount
    # @param [Object] phone
    def self.sendPaymentRequest(phone, amount)
      @billno   = rand(5**5)
      @amt      = amount
      @p        = phone

      #On genere le hash
      @hash   = Digest::MD5.hexdigest("#{$id}#{$p}#{@billno}#{@amt}#{@p}#{$k}")

      puts @hash
      puts "#{$id}#{$p}#{@billno}#{@amt}#{@p}#{$k}"

      #envoi de la requete
      @response = HTTParty.post($payment_request,
        body: {
            id:       $id,
            pwd:      $p,
            billno:   @billno, #rand(5**5),
            amount:   @amt,
            phone:    @p,
            hash:     @hash,
        },
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
                    timeout: 20
      )

      #on retourne le resultat, a finaliser
      if @response["statut"] == 100
        return {
            code: @response["statut"],
            message: @response["message"]
        }
      elsif @response["statut"] == 101
        return {
            code: @response["statut"],
            message: @response["message"]
        }
      end
      #return @response.as_json
    end

    #permet d'evoir le status du paiement 
    # @param [Object] phone
    # @param [Object] billno
    def self.getPaymentStatus(phone, billno)
      @p        = phone
      @billno   = billno

      @hash   = Digest::MD5.hexdigest("#{$id}#{$p}#{@billno}#{@p}#{$k}")

      @response = HTTParty.post($payment_status,
        body: {
          id:       $id,
          pwd:      $p,
          billno:   @billno, #rand(5**5),
          phone:    @p,
          hash:     @hash,
        },
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
        timeout: 20
      )

      #on retourne le resultat avec des conditions
      if @response["status"] == 0
        #la requete de payment a ete annulée
        return "Paiement annulé"
      elsif @response["status"] == 1
        return "Paiement réussi"
      elsif @response["status"] == 101
        return "Reference inexistante"
      else
        ApiMailer.notify("Code inconnu : #{@response["status"]}", @p, Time.now, "Une erreur est survenue, impossible d'indentifier le code #{@response}").deliver_now
        return "Une erreur est survenue durant le traitement"
      end
      #return @response["status"].as_json

    end


    #Permet de faire une recharge  de compte
    # @param [Object] phone
    # @param [Object] amount
    def self.cashin(phone, amount)
      @p        = phone
      @amount   = amount
      @ref      = rand(5**5)

      @hash     = Digest::MD5.hexdigest("#{$id}#{$p}#{@amount}#{@p}#{@ref}#{$k}")

      HTTParty.post($cashin,
        body: {
            id:           $id,
            pwd:          $p,
            amount:       @amount,
            phone:        @p,
            reference_id: @ref,
            hash:         @hash,
        },
        headers: { 'Content-Type' => 'application/x-www-form-urlencoded' },
        timeout: 20
     )
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