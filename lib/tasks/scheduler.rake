desc "This task is called by the Heroku scheduler add-on"
task :update_feed => :environment do
  puts "Updating feed..."
  # NewsFeed.update
  puts "done."
end

namespace :customer do
    desc "delete customer where account not used for 30 days and not activated"
    task :delete => :environment do
      puts "Starting searching and deleting only on friday"
      if Date.today.saturday?
        puts "We can start, we are on saturday"
        Customer.all.each do |customer|
          if customer.two_fa != 'authenticate' && customer.account.amount == '0.0' && (DateTime.now - customer.updated_at).to_i/(60*60*24) > 30 
            # customer is not authenticate and last update is 30 days
            Rails::logger::info "Searching customer with profile : Not authenticated, not update account since 30 days, don' have money in his/her accounte"
            # delete account first
            # if customer.account.destroy
            #   # delete customer virtual finance account firstly
            #   Rails::logger.info "Deleting customer account #{customer.account.id} ... DONE!"
            #   if customer.destroy
            #     # deleting customer personal account secondly
            #     Rails::logger::info "Deleting customer #{customer.phone} ... DONE!"
            #     # wait 2
            #     Sms.sender(customer.phone, "Votre compte vient d etre supprime de la plateforme PayMeQuick")
            #   else
            #     Rails::logger::info "Impossible de supprimer le compte #{customer.phone}"
            #     Sms.sender(App::PayMeQuick::App::developer[:phone], "Impossible de supprimer le compte #{customer.phone}")
            #   end
            # else
            #   Rails::logger::info "Impossible de supprimer le compte financier de #{customer.phone} : #{customer.account.id}"
            #   Sms.sender(App::PayMeQuick::App::developer[:phone], "Impossible de supprimer le compte financier #{customer.phone} : #{customer.account.id}")
            # end
            if customer.destroy
              # deleting customer personal account secondly
              Rails::logger::info "Deleting customer #{customer.phone} ... DONE!"
              # wait 2
              Sms.sender(customer.phone, "Votre compte vient d etre supprime de la plateforme PayMeQuick")
            else
              Rails::logger::info "Impossible de supprimer le compte #{customer.phone}"
              Sms.sender(App::PayMeQuick::App::developer[:phone], "Impossible de supprimer le compte #{customer.phone}")
            end
          #else
          #  Rails::logger::info "Aucune information a supprimer"
          #  Sms.sender(App::PayMeQuick::App::developer[:phone], "Aucune information a supprimer pour cette date : #{Date.today}")
          end
        end
      else

        Rails::logger::info "This day is not a friday, delection canceled!"
        Sms.sender(691451189, "Job canceled from Heroku at #{Time.now}: Cause: we are not a friday day.")

      end
      
    end

  desc "Send recapitulation of customers about total payment and total receive each week, on friday morning"
  task :recap => :environment do
    Customer.all.each do |customer|
      # Gel customer solde account
      solde = customer.account.amount

      # Get customer depenses for one week
      depense = History.where(customer_id: customer.id, flag: 'PAIEMENT').where(created_at: Date.today.beginning_of_week..Date.today.end_of_week).sum(:amount)

      # Get customer paiement recu for one week
      paiement = History.where(customer_id: customer.id, flag: 'ENCAISSEMENT').where(created_at: Date.today.beginning_of_week..Date.today.end_of_week).sum(:amount)

      # Last step, send SMS to customer.phone
      Sms.sender(customer.phone, "#{Client.prettyCallSexe(customer.sexe)} #{customer.complete_name}, Nous tenons a vous informer que vous avez depense #{depense} F CFA et recu #{paiement} F CFA cette semaine. Actuellement le solde de votre compte est de #{solde}.")

      # Logs sommes informations to Heroku console
      Rails::logger::info "Task has been generate to #{customer.phone} at #{Time.now}"
    end
  end

  desc "test avec active record"
  task :thanks => :environment do 
    Customer.all.each do |customer|
      if customer.two_fa == 'authenticate' && customer.account.amount != '0.0' 
        puts "Dire merci à l'utilisateurs #{customer.complete_name} en lui rappelant son"
        Sms.sender(customer.phone, "#{Client.prettyCallSexe(customer.sexe)} #{customer.complete_name} nous sommes fiert de vous savoir sur PayMeQuick et de vous informer que votre solde est actuellement de #{customer.account.amount}")
      end
    end
  end
end