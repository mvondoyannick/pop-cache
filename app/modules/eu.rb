#Module permettant de gerer les transactions Express Union
module Eu

  class Eu
    def initialize()

    end

    # permet d'envoyer les information de creer un compte vers l'API EUM
    def createEum

    end

    #permet de crediter un compte EUM via l'API EU
    def creditEum(phone, password, amount)

    end

    #permet de supprimer une compte EUM via l'API
    def deleteEum(phone, password)

    end

  end

  #classe pour la gestion des partenaires EU/EUM
  class EuPartner
    def initialize()

    end

    #creation d'un partenaire
    def createEuPartner(name, second_name, phone, cni)

    end
  end

end