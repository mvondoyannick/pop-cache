# MODELE DE GESTION DES INTENTION DE RETRAIT
class Await < ApplicationRecord
  before_save :set_hash
  before_destroy :restaure
  belongs_to :customer

  private
    #CREATION DE HASHAWAIT
    def set_hash
      self.hashawait = SecureRandom.hex(10) #la clé pour le hash courant
      self.end = 5.minutes.from_now
      self.used = false
    end

    #RESTAURATION DU COMPTE A LA DESTRUCTION D'UN ENREGISTREMENT D'INTENTION DE RETRAIT
    def restaure
      montant = self.amount

      # je mets a jour le solde du client
      account = Await.find(self.id).customer.account
      customer = Await.find(self.id).customer
      if account.blank?

        puts "Aucun utilisateur ne correspond a cette intention de retrait"
        Raise ActiveRecord::RecordNotFound "Pas de compte trouvé"

      else

        if account.update(amount: account.amount + montant.to_f)
          puts "Customer Updated"
        else
          puts "Une erreur est survenu"
        end

      end
      
    end

end
