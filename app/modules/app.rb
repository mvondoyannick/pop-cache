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
            version:      "0.1.1",
            revision:     "345"

        }
      end


      # GENERATE APP ID FOR BOTH ANDROID AND IOS
      def self.id
        return rand(10**10)
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