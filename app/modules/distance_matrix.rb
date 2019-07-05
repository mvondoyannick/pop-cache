module DistanceMatrix
  class DistanceMatrix

    def self.get_distance(lat1, long1, lat2, long2)
      @lat1 = lat1
      @lon1 = long1
      @lat2 = lat2
      @lon2 = long2

      #calcul de la distance
      distance = Geocoder::Calculations.distance_between([@lat1,@lon1], [@lat2,@lon2], units: :km)*1000
      if distance < 200000 #desactivation temporaire de la geolocalisation
          puts "Distance reelle (en metre) : #{distance} m"
          OneSignal::OneSignalSend.genericOneSignal("", "Vous etes trop loin de votre marchand pour effectuer cette opération", "You are far from your merchant to finalize this transaction")
          return true, distance
      else
          puts "Distance reelle (en metre): #{distance} m"
          return false, "Vous etes trop eloigné de votre vendeur!", distance
      end
    end


    #temps de duree du'un procedure
    def self.duration

    end


    #retourn l'adresse en fonction de la latitude et de la longitude
    # @param [Object] lat
    # @param [Object] lon
    def self.geocoder_search(lat, lon)
        @lat = lat.to_i
        @lon = lon.to_i
        results = Geocoder.search([lat, lon])
        return results.first.address
    end

    #Permet de rechercher via l'adresse IP
    # @param [Object] ip
    def self.pays(ip)
      @ip   = ip
      begin
        results = Geocoder.search(@ip)
        return results.first.country
      rescue Geocoder::NetworkError
        return "Une erreur reseau est survenu durant l'obtention des information sur l'adresse IP"
      rescue NoMethodError
        return "Impossible de continuer, une erreur FATAL est survenue"
      end
    end
    
  end  
end

