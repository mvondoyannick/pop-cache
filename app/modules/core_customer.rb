# Gestion des clients --  creation de compte, update, suppression, blocage
# @name CoreCustomer
module CoreCustomer

  class Customers

    # Create customer account
    # @param [Object] argv
    # @param [String] information
    # @param [String] langue
    def self.createAccount(argv, information, langue = nil)

      @name = argv[:name]
      @second_name = argv[:second_name]
      @phone = argv[:phone]
      @sexe = argv[:sexe]
      @type_id = argv[:type_id]
      @date_naissance = argv[:date_naissance]
      @cni = argv[:cni].present? ? argv[:cni] : "nil"
      @password = argv[:password]
      @device = argv[:device].present? ? argv[:device] : "platform"
      @ip = IPAddress.valid? argv[:ip] ? argv[:ip] : "::1"
      @pays = IPAddress.valid? argv[:ip] ? DistanceMatrix::DistanceMatrix.pays(@ip) : "Inconnu"
      @information = information
      @langue = langue

      puts argv
      puts self.as_json
      @customer = Customer.new(argv)
      if @customer.valid?
        puts "valid datas"
      else
        return false, @customer.errors.full_messages
      end


    end

    # Check if user have a valid year to subscribe to service
    # @param [Date] date
    def self.valid_date?(date)

      # @date.warn_invalid_date
      @date = date.strftime("%Y")

      #check if customer have more than 15 years
      if Date.today.year - @date > 15
        return true
      else
        return false, "Invalide Date, read conditions at https://paiemequick.com/account/conditions#min_age"
      end
    end

    # @param [Object] argv
    # @param [String] information
    # @param [String] langue
    def login(argv, information, langue = nil)

      @argv = argv
      @information = information
      @langue = langue
      
    end

    # @param [Object] argv
    # @param [String] information
    # @param [String] langue
    def updateAccount(argv, information, langue = nil)

      @argv = argv
      @information = information
      @langue = langue

    end

    # Update Customer password
    # @param [Object] argv
    # @param [String] information
    # @param [String] langue
    def updatePassword(argv, information, langue = nil)

      @prevPawword = argv[:prevPassword]
      @newPassword = argv[:newPassword]
      @customerToken = argv[:token]

      if Customer.exists?(authentication_token: @customerToken, two_fa: 'authenticate')

        @customer = Customer.find_by(authentication_token: @customerToken, two_fa: 'authenticate')

        # compare preview password to db password
        if @customer.valid_password?(@prevPawword)

          # starting update password
          if @customer.update(password: @newPassword)

            return true, "Password updated"

          else

            return false, "Password can't updated"

          end
        end

      else

        return false, "Unknow customer"

      end
      @information = information
      @langue = langue
    end

    def self.expiration

      hmac_secret = "s3cr3tpassword"
      exp = Time.now.to_i + 4 * 3600
      exp_payload = { data: 'data', exp: exp }
      token = JWT.encode exp_payload, hmac_secret, 'HS256'
      return token

    end

  end

end