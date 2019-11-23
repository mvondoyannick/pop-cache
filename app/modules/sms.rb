# SEND SMS FROM EVERYWHERE INSIDE THE APP
class Sms
    def initialize(phone, message)
      $phone = phone
      $message = message.encode("UTF-8", "Windows-1252")
    end

    # Definition des elements de base
    nexah_url = "https://smsvas.com/bulk/public/index.php/api/v1/sendsms"


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

    def self.mppp(msg)
      begin
        require 'httparty'
        moussi = "697085701"
        @msg = msg
        #@sunday_message_fr = "Suivez-nous sur Facebook https://web.facebook.com/ministereparlaparoleprophetique/ et Youtube : https://www.youtube.com/channel/UCU3kgsHKEXaeGe0BkTWAT2Q . Ministere Par la Parole Prophetique MPPP"
        #@sunday_message_en = "Follow us on Facebook https://web.facebook.com/ministereparlaparoleprophetique/ and Youtube https://www.youtube.com/channel/UCU3kgsHKEXaeGe0BkTWAT2Q . Ministry By the Prophetic Word MPPP"
        #@message = "Bonjour freres dans le Seigneur Jesus Christ, comme information nous sommes deja au nombre de 27 memebres pret a soutenir/combattre/mediter/prier/jeuner dans l'eglise pour l'oeuvre de Dieu. Notre groupe Whatsapp est https://chat.whatsapp.com/KFiT1BWtYIVDdNjXNy9v0S pour venir partager et discuter. Be bless"
        #@message_en = "Hello brothers in Jesus Christ. Do not forget the MPPP MEN'S MOVEMENT MEETING tonight, Tuesday, June 18, 2019 at 7PM, within the MPPP Ndokoti. In case of difficulties, thank you to inform Brother MOUSSI Emmanuel at #{moussi}. Be Blessed."
        #@message_fr = "Bonjour, nous n'avons pas encore fini de parler a Dieu pour notre Nation, notre situation, notre Ministere, nos freres/soeurs, nos projets, notre communaute ..., venez ce soir au MPPP a 19h crier a Dieu dans une priere de feu au sein du MOUVEMENT DES HOMMES. Be Blessed"
        @phone = %w(667720795 696128100 691905894 697335061 655513783 679161650 696207656 699554516 678875817 699554516 678875817 697386043 651865147 691451189 699627020 690349993 699354847 680300412 658768305 697823712 650669486 694662860 696444886 671483629 697085701 676114212 676667626 694168288 695961216 655047888 678681246 693640832 676690300 676114212 697823712 650669486 694349349 699554516 658029188 695992209 694195553 696768002 670579140 698994872)
        #@phone = %w(697335061 691451189 697085701)
        puts "#{@phone.count} numéro(s) recevront le message de #{@msg.length} caractere(s) via SMS!"
        @phone.each do |data|
          HTTParty.get("https://www.agis-as.com/epolice/index.php?telephone=#{data}&message=#{@msg}")
          puts "message send to #{data}"
        end
        return true, "envoyé à #{@phone.count} personnes à #{Time.now}"

      rescue StandardError, Timeout::Error, NetworkError::Error

        puts "Une error est survenue! La connexion internet semble etre instable"

      rescue => exception

        puts "Une erreur est survenue : #{exception}"

      end

    end

    def self.sender(phone, message)
      begin

        @phone    = phone
        @message  = message

        HTTParty.get("https://www.agis-as.com/epolice/index.php?telephone=#{@phone}&message=#{@message}")

      rescue => exception

        puts "Une erreur est survenue : #{exception}"

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

    # SEND SMS ENGINE NEXAH PLATEFORM
    # @param [String] phone
    # @param [String] message
    # @version 0.1
    def self.sms_engine(phone, msg)

      @msg = msg
      @phone = phone

      result = HTTParty.post("https://smsvas.com/bulk/public/index.php/api/v1/sendsms", 
        :body => { 
          user: "info@agis-as.com",
          password: "agis.as19",
          senderid: "MPPP",
          sms: @msg,
          mobiles: @phone
        }.to_json,
        :headers => { 
          'Content-Type' => 'application/json'
        } 
      )
      puts "DONE! Sending complete."
    end

    # CUSTOM MESSAGE PLATEFORM
    # @param [String] Mesasge, default nil
    def self.elem(msg=nil)

      @phone = "667720795 696128100 691905894 697335061 655513783 679161650 696207656 699554516 678875817 699554516 678875817 697386043 651865147 691451189 699627020 690349993 699354847 680300412 658768305 697823712 650669486 694662860 696444886 671483629 697085701 676114212 676667626 694168288 695961216 655047888 678681246 693640832 676690300 676114212 697823712 650669486 694349349 699554516 658029188 695992209 694195553 696768002 670579140 698994872 683206283"
      @msg = msg

      container = Array.new
      @phone.split(" ") do |content|
        container.push(content)
      end
      puts "elem contain : #{container}"
      container.each do |phone|
        puts "Starting sending SMS to #{phone} in progress ..."
        sms_engine(phone, @msg)
      end
    end

    def self.grouped(msg)
      @msg = msg
      result = HTTParty.post("https://smsvas.com/bulk/public/index.php/api/v1/sendsms", 
        :body => { 
          user: "info@agis-as.com",
          password: "agis.as19",
          senderid: "MPPP",
          sms: @msg,
          mobiles: "667720795 696128100 691905894 697335061 655513783 679161650 696207656 699554516 678875817 699554516 678875817 697386043 651865147 691451189 699627020 690349993 699354847 680300412 658768305 697823712 650669486 694662860 696444886 671483629 697085701 676114212 676667626 694168288 695961216 655047888 678681246 693640832 676690300 676114212 697823712 650669486 694349349 699554516 658029188 695992209 694195553 696768002670579140,  697085701,676114212,676667626,694168288,695961216,655047888,678681246,693640832,676690300,676114212,697823712,650669486,694349349,699554516"
        }.to_json,
        :headers => { 
          'Content-Type' => 'application/json'
        } 
      )

      #return response
      return result
    end

    # SEND SMS USING NEXAH PLATEFORM
    # using nexah SMS plateform
    # @param [String] phone
    # @param [String] message
    def self.nexah(phone, msg)
      puts "Starting nexah plateform API"

      @msg = msg
      @phone = phone

      #starting post request
      result = HTTParty.post("https://smsvas.com/bulk/public/index.php/api/v1/sendsms", 
        :body => { 
          user: "info@agis-as.com",
          password: "agis.as19",
          senderid: "PAYMEQUICK", #PAYMEQUICK
          sms: @msg,
          mobiles: @phone
        }.to_json,
        :headers => { 
          'Content-Type' => 'application/json'
        } 
      )

      puts "From nexah API : #{result}"

      #return response
      return result

    end
end