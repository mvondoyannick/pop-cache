class Parametre
    require 'jwt'
    $percentage = 1.5
    $hmac_secret = "my$ecretK3y"

    #retourne le montant majoré du client
    def self.agis_percentage(amount)
        @amount = amount
        tmp = (@amount*$percentage)/100
        converted = @amount + tmp
        puts converted
        return converted
    end

    #permet de decoder une chaine precedement code avec JWT
    ##utilisation de l'algorythme cryptographique HMAC
    def self.decode_jwt(chaine)
        @chaine = chaine
        token = JWT.decode @chaine, $hmac_secret, true, {algorithm: 'HS256'}
        return true, token[0]
    end

end