module logs

  #quelques informations publiques
  $time = Time.now
  $request_id = 1

  class Journal
      def initialize(attribute)
        @attribute = attribute
      end

      def self.log_login(phone, android, lat, lon)
        @phone = phone
        @android = android
        @lat = lat
        @lon = lon
      end
  
      def self.create_logs_transaction(client_phone, marchand_phone, amount)
          @client_phone   = client_phone
          @marchand_phone = marchand_phone
          @amount         = amount
          @date           = Time.now
          @client_name    = Customer.where(phone: @client_phone).first.name
          @marchand_name  = Customer.where(phone: @marchand_phone).first.name
  
          #puts request.remote_ip
  
          #creation du journale de transaction
          journal = Transaction.new(
              date: @date,
              client_phone: @client_phone,
              client_name: @client_name,
              marchand_phone: @marchand_phone,
              marchand_name: @marchand_name,
              amount: @amount
          )
          if journal.save
              puts "New entry created"
              return "New entry created"
          else
              puts "impossible de creer le journale. Errors : #{journale.errors.messages}"
              return "impossible de creer le journale. Errors : #{journale.errors.messages}"
          end
      end
  
  end

  #class pour journaliser les activités des entreprises
  class JournaleEntreprise
  end

  class JournalDepot
  end

  class JournalRetrait
  end
  
end
