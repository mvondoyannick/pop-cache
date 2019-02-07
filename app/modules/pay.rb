class Pay

    include HTTParty

    HEADERS = {
        "Authorization": "SP:2c110723-f334-4638-a610-1d575eefd60f:MjBmNjBjNzg5YmE3MWYwYTAxM2Y4Nzg3ODViYjRlOTRkZjAwYTYxMg==",
        "DateTime": "2018-12-05T18:55:25Z",
        "Content-Type": "application/json"
    }

    def initialize(phone, amount)
        $phone = phone
        $amount = amount
    end

    def self.send(body)
        #https://test-api.sprint-pay.com/sprintpayapi/payment/mobilemoney/request/v3
        q = HTTParty.post('https://test-api.sprint-pay.com/sprintpayapi/payment/orangemoney/request/v3', headers: HEADERS, body: body)
        return q.as_json
    end

    def self.pay_orange
      body_data = {
          "phone": $phone, #utiliser la variable globale disponible a cet effet
          "amount": $amount       #utiliser le montant globale disponible a cet effet
      }.to_json

      send(body_data)
    end

    def self.pay_mtn
      body_data = {
          "phone": $phone, #utiliser la variable globale disponible a cet effet
          "amount": $amount       #utiliser le montant globale disponible a cet effet
      }.to_json

      send(body_data)
    end

    #permet d'effectuer la verification du telephone
    def self.checkPhone
    end

    #permet de verifier le formar du paiement
    def self.checkAmount
        if $amount.is_a?(String)
            return false
          elsif $amount.is_a?(Integer)
            return true
        end
    end

    #paiement via OM
    def self.pay

    end

end