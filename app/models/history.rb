class History < ApplicationRecord
  belongs_to :customer

  before_save :set_color
  before_save :set_ipadress  #convertis un adresse IP en region

  private
  def set_color
    self.color = "#1976d2" if self.flag == "PAIEMENT"     #rouge
    self.color = "#388e3c" if self.flag == "ENCAISSEMENT" #vert
    self.color = "#e53935" if self.flag == "RETRAIT"      #rouge
    self.color = "#fbc02d" if self.flag == "RECHARGE"     #jaune
    self.color = "#ab47bc" if self.flag == "ABONNEMENT"   #violet
  end

  def set_ipadress
    self.region = DistanceMatrix::DistanceMatrix.pays(self.ip) if self.ip != nil
  end

  def self.generate_csv
    attributes = %w{ id customer flag amount created_at}
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |history|
        csv << history.attributes.values_at(*attributes)
      end
    end
  end
end
