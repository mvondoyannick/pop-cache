# SEND SMS FROM EVERYWHERE INSIDE THE APP
class Sms
    def initialize(phone, message)
        $phone = phone
        $message = message.encode("UTF-8", "Windows-1252")
    end


    def self.send
        require 'httparty'

        status = HTTParty.get("https://www.agis-as.com/epolice/index.php?telephone=#{$phone}&message=#{$message}")
        #envoi du SMS via HTTPatrty

        return true, status.as_json(only: ["date", "connection"])
    end

    def self.resend
        require 'httparty'

        HTTParty.get("https://www.agis-as.com/epolice/index.php?telephone=#{$phone}&message=#{$message}")
        #envoi du SMS via HTTPatrty

        return true
    end

    def self.mppp
      begin
        require 'httparty'
        moussi = "697085701"
        #@message = "Bonjour freres dans le Seigneur Jesus Christ, comme information nous sommes deja au nombre de 27 memebres pret a soutenir/combattre/mediter/prier/jeuner dans l'eglise pour l'oeuvre de Dieu. Notre groupe Whatsapp est https://chat.whatsapp.com/KFiT1BWtYIVDdNjXNy9v0S pour venir partager et discuter. Be bless"
        @message_en = "Hello brothers in Jesus Christ. Do not forget the MPPP MEN'S MOVEMENT MEETING tonight, Tuesday, June 18, 2019 at 7PM, within the MPPP Ndokoti. In case of difficulties, thank you to inform Brother MOUSSI Emmanuel at #{moussi}. Be Blessed."
        @message_fr = "Bonjour, nous n'avons pas encore fini de parler a Dieu pour notre Nation, notre situation, notre Ministere, nos freres/soeurs, nos projets, notre communaute ..., venez ce soir au MPPP a 19h crier a Dieu dans une priere de feu au sein du MOUVEMENT DES HOMMES. Be Blessed"
        @phone = %w(667720795 696128100 691905894 697335061 655513783 679161650 696207656 699554516 678875817 699554516 678875817 697386043 651865147 691451189 699627020 690349993 699354847 680300412 658768305 697823712 650669486 694662860 696444886 671483629 697085701 676114212 676667626 694168288)
        #@phone = %w(691451189 691451189)
        puts "#{@phone.count} numéro(s) seront notifiés via SMS!"
        @phone.each do |data|
          HTTParty.get("https://www.agis-as.com/epolice/index.php?telephone=#{data}&message=#{@message_fr}")
          puts "message send to #{data}"
        end
        return true, "envoyé à #{@phone.count} personnes à #{Time.now}"

      rescue StandardError, Timeout::Error, NetworkError::Error

        puts "Une error est survenue! La connexion internet semble etre instable"

      end

    end

    def self.sender(phone, message)
      begin

        @phone    = phone
        @message  = message

        HTTParty.get("https://www.agis-as.com/epolice/index.php?telephone=#{@phone}&message=#{@message}")

      rescue StandardError, TimeoutError::Error, NetworkError::Error

        Rails::logger.info "Une erreur est survenue"

      end

    end

    # Send notification to many users
    # @param [Object] argv
    def self.sms_to_many(argv, message="empty SMS")

      argv.each do |key, value|
        begin

          puts "Starting sending sms to ... #{value}, with message #{message}"
          request = HTTParty.get("https://www.agis-as.com/epolice/index.php?telephone=#{value}&message=#{message}")

        rescue StandardError => e

          puts "Une erreur est survenue : #{e}"

        end

      end

    end
end