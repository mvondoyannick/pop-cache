# APP BASIC INFORMATIONS
## App::
module App

  module PayMeQuick

    class App

      # return application name
      # @return [String]
      def self.app
        return {
          name:         "paymequick",
          signature:    "PayMeQuick",
          domaine:      "paiemequick.com",
          version:      "1.0.1",
          revision:     "345"

        }
      end


      # GENERATE APP ID FOR BOTH ANDROID AND IOS
      def self.app_id
        include ActionDispatch
        require 'securerandom'
        return SecureRandom.uuid
      end

      # All limites are define here, for customer who don't have account
      def self.limit
        return {
            limit_amount: 150000,
            limit_transaction_recharge: 50000,
            limit_transaction_recharge_jour: 2500000,
            limit_day_transaction: 100
        }
      end

      def self.developer
        return {
            name: "MVONDO Yannick",
            email: "mvondoyannick@gmail.com",
            phone: "691451189"
        }
      end

      def self.devise
        return "F CFA"
      end

      #retourne la clé secrete
      def self.key
        return Rails.application.secrets.secret_key_base
      end
    end

  end

  module Messages

    # Tout ce qui concerne les messages de login
    class Authentication

      def self.message
        return {
            login: {
                fr: {

                },
                en: {

                }
            }
        }
      end

      def self.success

      end

      def self.errors

      end

    end

    class Signup

      def self.confirmation

        return {
          sms: {
            confirmation_failed: "Impossible d'envoyer le SMS de confirmation",
            customer_exist: "Impossible de creer un nouvel utilisateur car il est deja existant"
          }
        }

      end

    end


    class Errors

    end

    class Success

    end
  end
end