module Fraud

    class Customer

        # CHECK FRAUD ON CUSTOMER PASSWORD
        # @param [String] password
        # @return [Boolean] boolean
        # @version 1.0.0
        def self.passwordValidation(password)
            @password   = password
            restrcit = %w(111111 123456 000000 654321 222222 333333 444444 555555 666666 777777 888888 999999 )
            if @password.in?(restrcit)
                return false, "Ce mot de passe n'est pas authorisé"
            else
                return true, "valid password"
            end
        end


        # LIMIT LOGIN TENTATIVE
        # @param [String] customer
        # @param [String] password
        # @return [Object] Object
        def self.limitLoginAttempt(customer, password)
            @customer = customer
            @password = password

            #on recupere la derniere date de la derniere activité renseignée
            activity = CustomerDatum.find_by_customer_id(@customer)
            if activity.blank?
                return false, "Unknow activity for this customer"
            else
                #if Time.now 
            end

            saving = CustomerDatum.new(
                motif: "bad pwd",
                customer: @customer,
                bad_password: @password,
                ip: "IP Adress",
                compteur: CustomerDatum.find_by_customer_id(@customer).compteur += 1 
            )
        end
    end

    #class Localization
    #end

    #class Transaction
    #end
end