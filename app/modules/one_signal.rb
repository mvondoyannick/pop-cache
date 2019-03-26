module OneSignal

  include HTTParty
  include Faraday
  include ActiveRecord

  #definition des heraders pour l'envoi en post
  HEADERS = {
      "Authorization" => "Basic YWJkNzQwYzAtMmYyNC00MDY2LTlmYTMtZjI0ZDc4ZTljMDk5",
      "Content-Type" => "application/json"
  }

  class OneSignalSend

    # Create new file to storage log of pushes.
    @push_logger = ::Logger.new(Rails.root.join('log', 'push.log'))

    # Every request needs to inform the APP ID.
    @body =  {
        "app_id" => '968c918a-8cd0-4e24-9bf4-f277782f4d09'
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
              "url" => "https://onesignal.com",
              "data" => { "type": "daily_news" },
              "contents" => { "en" => "News!", "pt" =>  "Novidades!" }
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


    def self.bonjour(args)
      @args = args
      push_body = @body.merge(
          {
              "contents"=> {"en"=> @args},
              "included_segments"=> ["All"]
          }
      ).to_json
      #return 'bonjour'
      send_push(push_body)
    end

  end

end