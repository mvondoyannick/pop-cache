class DistanceMatrix

    def self.get_distance(lat1, long1, lat2, long2)
        @lat1 = lat1
        @lon1 = long1
        @lat2 = lat2
        @lon2 = long2

        #calcul de la distance
        distance = Geocoder::Calculations.distance_between([@lat1,@lon1], [@lat2,@lon2], units: :km)*1000
        if distance < 1000
            puts distance
            return true, distance
        else
            puts distance
            return false, "Trop éloigner", distance
        end
    end


    #temps de duree du'un procedure
    def self.duration

    end


    #retourn l'adresse en fonction de la latitude et de la longitude
    def self.geocoder_search(lat, lon)
        @lat = lat
        @lon = lon
        results = Geocoder.search([@lat, @lon])
        return results.first.address
    end
    
end