module CustomerClient
  class PayWithCode

    def self.pay
      return nil
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