module OneSignal

  include HTTParty
  include Faraday
  include ActiveRecord

  #definition des heraders pour l'envoi en post
  HEADERS = {
      "Authorization" => "Basic OTFlOGFjYzEtMzRkOC00OTNmLWJkOTAtMjQ2YzM2MWQ0N2Zm",
      "Content-Type" => "application/json"
  }

  class OneSignalSend

    # Create new file to storage log of pushes.
    @push_logger = ::Logger.new(Rails.root.join('log', 'push.log'))

    # Every request needs to inform the APP ID.
    @body =  {
        "app_id": '680b2111-1439-4700-b338-2357cd10074b'
    }

    def self.send_push(body)
      #TODO penser à desactiver des nous passerons en HTTPS (production)
      HTTParty::Basement.default_options.update(verify: false)
      HTTParty.post 'https://onesignal.com/api/v1/notifications', headers: HEADERS, body: body, logger: @push_logger, log_level: :debug, log_format: :curl
    end

    # Send push to all users.
    def self.daily_news
      push_body = @body.merge(
          {
              "included_segments" => ["All"],
              "url" => "",
              "data" => { "type": "daily_news" },
              "contents" => { "en" => "News!", "pt" =>  "Novidades!", "fr" => "Actualites" }
          }).to_json

      send_push(push_body)
    end

    #nouvelle alerte pour les partenaires
    # send_alertes to all users who has subscribing to plateform app android
    def self.new_alerte(service, alert_id)
      @service = service #string value for service user concerné
      @alert_id = alert_id #id de l'alerte
      push_body = @body.merge(
          {
              #"headings"=> {"en"=> "E-POLICE PARTNOTIFICATIONS ALERTES"},
              "contents"=> {
                  "en"=> @service,
                  "fr"=> @service
              },
              "included_segments"=>["All"],
              "android_sound"=> "notification",
              "android_led_color"=> "FF0000FF",
              "android_accent_color"=> "FFFF0000",
              "android_group_message"=> {
                  "fr": "Vous avez $[notif_count] nouveaux messages",
                  "en": "You have $[notif_count] new messages"
              },
              "data"=> {"id_alert": @alert_id}
          }
      ).to_json
      send_push(push_body) #envoi des notification push
    end

    #recuperer l'id du telephone
    # @param [OneSignalObject] playerId
    # @param [IntegerObject] amount
    # @param [Object] merchant
    def self.sendNotification(playerId, amount, merchant, customer)
      @playerId   = playerId
      @amount     = amount
      @merchant   = merchant
      @customer   = customer

      push_body = @body.merge(
          {
              #"included_segments" => ["All"],
              "include_player_ids" => [@playerId],
              "button" => [{"id": "id1", "text": "button1", "icon": "ic_menu_share"}, {"id": "id2", "text": "button2", "icon": "ic_menu_send"}],
              "url" => "",
              "send_after" => 5.seconds.from_now,
              "data" => {"type": "PAIEMENT", payeur: "#{@customer}", marchand: "#{@customer}", montant: "#{@amount}", date: Time.now},
              "contents"=> { "en"=> "Payment done! amount of #{@amount} F CFA to #{@merchant}. PayQuick", "fr"=> "Transaction effectuée, montant de #{@amount} F CFA payé à #{@merchant}. PayQuick" }
          }).to_json

      send_push(push_body)
    end


    #message generale aux client payquick
    def self.generalNotification(msg)
      @msg    = msg
      push_body = @body.merge(
          {
              "included_segments" => ["All"],
              "url" => "https://agis-as.com",
              "data" => { "type": "daily_news" },
              "contents" => { "en": "News!", "fr": "#{@msg}" }
          }).to_json

      send_push(push_body)
    end

    #On ne peut pas se payer a sois meme
    # @param [Object] playerId
    # @param [Object] user
    def self.notPayToMe(playerId, user)
      @playerId     = playerId
      @user         = user

      push_body = @body.merge(
          {
              "include_player_ids" => [@playerId],
              "send_after" => 1.seconds.from_now,
              "data" => {"type": "PAIEMENT", payeur: "#{@customer}", marchand: "#{@customer}", montant: "#{@amount}", date: Time.now},
              "contents"=> { "en"=> "#{user} you can not pay yourself. PayQuick", "fr"=> "#{@user} vous ne pouvez pas vous payer a vous même. PayQuick" }
          }).to_json

      send_push(push_body)

    end

    #montant de le compte est insuffisant
    # @param [Object] playerId
    # @param [Object] user
    # @param [Integer] amount
    def self.montantInferieur(playerId, user, amount)
      @playerId     = playerId
      @user         = user
      @amount       = amount

      push_body = @body.merge(
        {
        "include_player_ids": [@playerId],
            "send_after": 1.seconds.from_now,
        "data": { "type": "PAIEMENT", payeur: "#{@customer}", marchand: "#{@customer}", montant: "#{@amount}", date: Time.now},
            "contents": { "en": "#{@user} your account amount is les than #{@amount} F CFA to process this payment. PayQuick", "fr": "#{@user} le montant de votre compte est inferieur à #{@amount} F CFA pour effectuer cette transaction. PayQuick" }
      }).to_json

      send_push(push_body)
    end

    #distance superieur a ce qui est demandée
    # @param [Object] playerId
    # @param [Object] msgFr
    # @param [Object] msgEn
    def self.genericOneSignal(playerId, msgFr, msgEn)
      @playerId     = playerId
      @msgFr        = msgFr
      @msgEn        = msgEn

      push_body = @body.merge(
          {
              "include_player_ids" => [@playerId],
              #"send_after": 1.seconds.from_now,
              "contents" => {"en" => "#{@msgEn}. PayQuick", "fr" => "#{msgFr}. PayQuick"}
          }).to_json

      send_push(push_body)

    end

    #Notification de retrait d'argent
    def self.retraitOneSignal(playerId, msgFr, msgEn)
      @playerId     = playerId
      @msgFr        = msgFr
      @msgEn        = msgEn

      push_body = @body.merge(
          {
              "include_player_ids" => [@playerId],
              #"send_after": 1.seconds.from_now,
              "contents" => {"en" => "#{@msgEn}. PayQuick", "fr" => "#{msgFr}. PayQuick"}
          }).to_json

      send_push(push_body)
    end

  end

end