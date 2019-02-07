class Sms
    def initialize(phone, message)
        $phone = phone
        $message = message
    end


    def self.send
        require 'httparty'

        HTTParty.get("https://www.agis-as.com/epolice/index.php?telephone=#{$phone}&message=#{$message}")
        #envoi du SMS via HTTPatrty

        return true
    end

    def self.resend
        require 'httparty'

        HTTParty.get("https://www.agis-as.com/epolice/index.php?telephone=#{$phone}&message=#{$message}")
        #envoi du SMS via HTTPatrty

        return true
    end
end