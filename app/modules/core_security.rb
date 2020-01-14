#secure all transaction
# @name CoreSecurity
module CoreSecurity

    $version = "1.0.0"

    # Gestion de la sécurité
    class Guardian

    end

    # managing fraud
    class Fraud

        # 3DSecure transaction
        # @param [Object] argv
        # @param [String] intent
        # @param [String] langue
        def self.secureTransaction(argv, intent, langue = nil)

            @argv = argv
            @intent = intent
            @langue = langue

        end

    end

    class Client

        # VERIFIE SI LE CLIENT A UNE VERSION COMPATIBLE POUR ECHANGER AVEC L'API
        # @params [Integer] version
        def is_client_valid?(ver)
            @version = version
            if @version >= $version
                return true
            else
                return false
            end
        end
    end

    class Security

    end
end