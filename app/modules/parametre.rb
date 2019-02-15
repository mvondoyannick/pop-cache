class Parametre
    $percentage = 1.5

    #retourne le montant majoré du client
    def self.agis_percentage(amount)
        @amount = amount
        tmp = (@amount*$percentage)/100
        converted = @amount + tmp
        puts converted
        return converted
    end

end