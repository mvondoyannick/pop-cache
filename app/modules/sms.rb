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

    def self.many
      begin
        require 'httparty'
        moussi = "697085701"
        #@message = "Bonjour freres dans le Seigneur Jesus Christ, comme information nous sommes deja au nombre de 27 memebres pret a soutenir/combattre/mediter/prier/jeuner dans l'eglise pour l'oeuvre de Dieu. Notre groupe Whatsapp est https://chat.whatsapp.com/KFiT1BWtYIVDdNjXNy9v0S pour venir partager et discuter. Be bless"
        @message_en = "
Hello brothers in Jesus Christ. Do not forget the MPPP MEN'S MOVEMENT MEETING tonight, Tuesday, June 18, 2019 at 7PM, within the MPPP Ndokoti. In case of difficulties, thank you to inform Brother MOUSSI Emmanuel at #{moussi}. Be Blessed."
        @message = "Bonjour Freres en Jesus Christ. N'oubliez pas la reunion du MOUVEMENT DES HOMMES DU MPPP de ce soir Mardi 09 juillet 2019 a 19H precise au sein du MPPP Ndokoti. En cas de difficultes, merci de notifier le frere MOUSSI Emmanuel au #{moussi}. Be Blessed."
        @phone = %w(667720795 696128100 691905894 697335061 655513783 679161650 696207656 699554516 678875817 699554516 678875817 697386043 651865147 691451189 699627020 690349993 699354847 680300412 658768305 697823712 650669486 694662860 696444886 671483629 697085701 676114212 676667626 694168288)
        #@phone = %w(691451189 691451189)
        puts "#{@phone.count} numéro(s) seront notifiés via SMS!"
        @phone.each do |data|
          HTTParty.get("https://www.agis-as.com/epolice/index.php?telephone=#{data}&message=#{@message_en}")
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

    #inclusion de faraday
    def self.fylo
      require 'faraday'
      conn = Faraday.new(:url => 'https://www.agis-as.com/epolice')
      conn.get '/index.php', { telephone: $phone, message: $message }
      return conn
    end
end