class Lorem

  Rails.logger = Logger.new(Rails.root.join('log', 'lorem.log'))

  def self.create(argv)
    @token = argv[:token]
    @context = argv[:context]

    #chaine = {
    #    token: @token,
    #    context: @context
    #}

    chaine = "#{@token}@#{nil}@#{nil}@#{nil}@plateform#{nil}"

    key = "cb20a3730d9e3f067ed91a6e458da82d"

    #encoder la chaine
    encoded = AES.encrypt(chaine, key)

    #puts encoded


    #on genere le QR code
  end

  def self.amount(a)
    key = Rails.application.secrets.secret_key_base
    a = a
    final = JWT.encode a, key, 'none'
    return final
  end

  def self.lang(locale)
    # puts I18n.locale = :fr
    Rails::logger.warn "init process langage"
    puts I18n.t("PasswordNotSecure", locale: locale)
  end

  def self.qrcode

    begin

    a = {
        customer: {
            token: 'lorem'
        },
        merchant: {
            token: 'agence'
        },
        transaction: {
            reference: "sdflkj098sdkfj",
            amount: 25000,
            device: 'xaf',
            detail: 'description'
        },
        geo: {
            lat: 0,
            long: 0,
            ip: "192.168.1.1"
        },
        context: "plateform"
    }

    rescue JWT::DecodeError

      return "une erreur de decodage est survenue"

    rescue LoadError

      return "une erreur de chargement est survenue"

    end

  end

  def self.created(argv)
    @a = argv
    puts History.new(@a)
    return @a.as_json
  end

  def self.decrypt
    puts value = AES.decrypt("vRvn36V1323VFtMg2q6K3w==$KeCV4Qe5sCjyajIfIe5NcCn6KgGk+dAskXv2BBnA9X8=", "cb20a3730d9e3f067ed91a6e458da82d")
    puts value["token"]
    puts value["plateform"]
  end
end