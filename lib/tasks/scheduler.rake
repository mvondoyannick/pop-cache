desc "This task is called by the Heroku scheduler add-on"
task :update_feed => :environment do
  puts "Updating feed..."
  # NewsFeed.update
  puts "done."
end

namespace :customer do
    desc "delete customer where account not used for 30 days and not activated"
    task :delete => :environment do
      puts "Starting searching and deleting only on saturday ..."
      if Date.today.saturday?
        puts "We can start, we are on saturday"
        Customer.all.each do |customer|
          if customer.two_fa != 'authenticate' && customer.account.amount == '0.0' && (DateTime.now - customer.updated_at).to_i/(60*60*24) > 30 
            # customer is not authenticate and last update is 30 days
            puts "Searching customer with profile : Not authenticated, not update account since 30 days, don' have money in his/her accounte"
            # delete account first
            if customer.destroy
              # deleting customer personal account secondly
              puts "Deleting customer #{customer.phone} ... DONE!"
              # wait 2
              Sms.nexah(customer.phone, "Votre compte vient d etre supprime de la plateforme PayMeQuick")
            else
              puts "Impossible de supprimer le compte #{customer.phone}"
              Sms.nexah(App::PayMeQuick::App::developer[:phone], "Impossible de supprimer le compte #{customer.phone}")
            end
          #else
          #  Rails::logger::info "Aucune information a supprimer"
          #  Sms.sender(App::PayMeQuick::App::developer[:phone], "Aucune information a supprimer pour cette date : #{Date.today}")
          end
        end
      else

        puts "This day is not a friday, delection canceled!"
        Sms.nexah(691451189, "Job canceled from Heroku at #{Time.now}: Cause: we are not a friday day.")

      end
      puts "DONE!"
    end

  desc "Send recapitulation of customers about total payment and total receive each week, on friday morning"
  task :recap => :environment do
    if Date.today.sunday?
      Customer.all.each do |customer|

        if customer.two_fa == 'authenticate'
          # Gel customer solde account
          solde = customer.account.amount
    
          # Get customer depenses for one week
          depense = History.where(customer_id: customer.id, flag: 'PAIEMENT').where(created_at: Date.today.beginning_of_week..Date.today.end_of_week).sum(:amount)
    
          # Get customer paiement recu for one week
          paiement = History.where(customer_id: customer.id, flag: 'ENCAISSEMENT').where(created_at: Date.today.beginning_of_week..Date.today.end_of_week).sum(:amount)

          #recharge 
          recharge = History.where(customer_id: customer.id, flag: 'RECHARGE').where(created_at: Date.today.beginning_of_week..Date.today.end_of_week).sum(:amount)
    
          # Last step, send SMS to customer.phone
          Sms.nexah(customer.phone, "#{Client.prettyCallSexe(customer.sexe)} #{customer.complete_name}, Nous tenons a vous informer que vous avez recharge votre compte de #{recharge.round(2)} F CFA, effectue des depenses de #{depense.round(2)} F CFA et recu des paiements de #{paiement.round(2)} F CFA cette semaine (#{Date.today.beginning_of_week} a #{Date.today.end_of_week}). Votre solde est actuellement de #{solde.round(2)} F CFA.")
    
          # Logs sommes informations to Heroku console
          puts "Task has been generate to #{customer.phone} at #{Time.now}"
        end
      end
    else
      Rails::logger::info "We are not a saturday, Job canceled"
    end
  end

  desc "Remercier l'utilisateur pour sa presence sur la plateforme PayMeQuick"
  task :thanks => :environment do 
    if Date.today.saturday?
      Customer.all.each do |customer|
        if customer.two_fa == 'authenticate' && customer.account.amount != '0.0' 
          puts "Dire merci à l'utilisateurs #{customer.complete_name} en lui rappelant son"
          Sms.nexah(customer.phone, "#{Client.prettyCallSexe(customer.sexe)} #{customer.complete_name} nous sommes fiert de vous savoir sur PayMeQuick et de vous informer que votre solde est actuellement de #{customer.account.amount} F CFA")
        end
      end
    else
      Rails::logger::info "We are not on monday! can't excecute Job!"
    end
  end

  desc "Supprimer automatiquement tous les retraits perimés"
  task :retrait_perime => :environment do
    puts "Recherche des intentions de retrait périmés ..."
    Await.all.each do |intent|
      if intent.blank?
        puts "Aucune intention de retrait trouvé, Annulé"
      else
        if DateTime.now > intent.end 
          # les intentions de retraits sont deja périmés, elles doivent etre supprimées
          puts "Customer phone number : #{intent.customer.phone}"
          Sms.nexah(intent.customer.phone, "Retrait annulé, delais de la transaction depasse. Paymequick. Link : https://byt.li/pmq/web/2398")
          if intent.destroy
            puts "Intent #{intent.id} supprimé. Cause: delais de retrait dépassé"
          else
            puts "Impossible de supprimer cet intention de retrait périmé"
          end
        else
          puts "Aucunes intention de retrait périmés trouvés, action annulée!"
        end
      end
    end
    puts "DONE!"
  end
end