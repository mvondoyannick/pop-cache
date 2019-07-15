class Lorem

  def self.Create(argv)
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

  def self.qrcode
    a = {
        customer: {
            token: 'lorem'
        },
        merchant: {

        },
        transaction: {
            amount: 250,
            device: 'xaf',
            detail: 'description'
        },
        service: {
            category: 1,
            service: 'bus'
        },
        products: {
            qty: 3,
            name: 'sue'
        },
        geo: {
            lat: 0,
            long: 0,
            ip: "192.168.1.1"
        },
        api: {
            return_url: 'home'
        }
    }
  end

  def self.Created(argv)
    @a = argv
    puts History.new(@a)
    return @a.as_json
  end

  def self.Decrypt
    puts value = AES.decrypt("vRvn36V1323VFtMg2q6K3w==$KeCV4Qe5sCjyajIfIe5NcCn6KgGk+dAskXv2BBnA9X8=", "cb20a3730d9e3f067ed91a6e458da82d")
    puts value["token"]
    puts value["plateform"]
  end
end