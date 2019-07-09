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

    def self.Decrypt
        puts value = AES.decrypt("vRvn36V1323VFtMg2q6K3w==$KeCV4Qe5sCjyajIfIe5NcCn6KgGk+dAskXv2BBnA9X8=","cb20a3730d9e3f067ed91a6e458da82d")
        puts value["token"]
        puts value["plateform"]
    end
end