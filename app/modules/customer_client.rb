module CustomerClient
  class PayWithCode

    def self.pay
      return nil
    end
    
  end



  class Client
    def self.get_customer(phone)
      @phone = phone

      query = Customer.where(phone: @phone).first
      return query
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