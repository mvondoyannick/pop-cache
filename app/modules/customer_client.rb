module CustomerClient
  class PayWithCode

    def self.pay
      return nil
    end

    #Payer avec le code MIN
    # @param [Object] min
    # @param [Object] token
    def self.check(min, token)
      @min      = min
      @token    = token

      customer = Customer.find_by_authentication_token(@token)
      if customer.blank?
        return false, "Customer not found"
      else
        Rails::logger.info "Searche merchant information ..."
        merchant = Customer.find_by_code(@min)
        if merchant.blank?
          return false, "Utilisateur inconnu"
        else
          #On verifie que le marchand ne peut pas se payer lui meme
          Rails::logger.info "Customer and merchant are same #{customer.phone}"
          if customer.authentication_token.eql?(merchant.authentication_token)
            return false, "Impossible de vous payer a vous meme"
          else
            Rails::logger.info "Marchant idenfified"
            return true, merchant.as_json(only: [:name, :second_name, :authentication_token])
          end
        end
      end
    end
    
  end



  class Client
    def self.get_customer(phone)
      @phone = phone.to_i

      query = Customer.where(phone: @phone).first
      if query.blank?
        return false, "#{@phone} n'est pas client de la plateforme"
      else
        return true, query
      end
    end

    #retourner toutes les questions au client mobile
    def self.get_all_question
      questions = Question.all
      if questions.blank?
        return false
      else
        return questions
      end
      return questions
    end

    #retourn une question specifique
    def self.get_question(id)
      question_id = id
      question = Question.find(question_id)
      if question.blank?
        return false
      else
        return question
      end
    end

    #retrouvons le mot de passe perdu/oublié du client
    def self.retrieve_password(phone, question, answer)
      @phone      = phone
      @question   = question
      @answer     = answer
    end

  end

end