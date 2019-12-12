module CoreSecurity

    $version = "1.0.0" 
    $rsa_private = "-----BEGIN RSA PRIVATE KEY-----
    MIIEpAIBAAKCAQEA3DFV+vij74ZsNsRS/wQgmZEYs1k68Ym3q5xq1/D2QO2AH4Wu
    /I5Mo0HOSwa+uaL3U3HaN7u4U+6hmLmSiiUGq6yF3THgUK1Q6opSvUvoZ5MTcJHm
    /t3vWqkGAp8CmXoMNEXM3iohC/8ZaA4tkz7E0XXbDBjczZFVbATGAu/ocn05k7U8
    aoghweuxvNR4+kYZ1M05afo8QmtDBuPLB2X4Nuc3RS9qn28oKbbFILUJo4mToUC+
    kDSJ6NZQpPDKJHswx8ukX1kjF2srXG1svxBn7b4QLxQ8yKYFaAlBDYxWFTifIAay
    SBpQ7USrREtqPKG39hhFWrDIQDfcJK6fRnQHqwIDAQABAoIBADPnDTVTVpEnRmrC
    bC3gcy6/nOrppZM5uymgfS7ZhbJYSVMk19KAWGBDKrVUqbBoUZRBygZJIXHnVgAB
    /iDCCYh96i/xicZ6lBA0+rvUILwJVxO50JFTDxB3twr3IE29DxNjQJ89nvyM7Rgx
    /1wt94bIGRII6kMqdtA3b9VRZ6FUovhwsUYxZhC4BCMBPOxb6HqB6JcaJtKyGdS+
    yVQTbgXQtgmx5FIswm6l9Ha/qeC6u3P5u0zBciFpz6Z1p+aubNjeNWCqO6nuy1z9
    457oLPsXutt4t89I/IifwzkB66DLM01S3CeVWuBDs5LmCkHleFu1wKYMeCVjr6XY
    uVCEZkECgYEA/8VxkRa6gH4s70fK0xpMwFt8Z1XCqY/V/GK5wC9SA8NI06x0NsRp
    argCL2maMrwuIKv5iTt1D5HrCz9pAK5uzXoHZ1Y/TYtspM0zo8GaTH+rL7ayzcNB
    YeOytAM6gI94Ai+B6Hju8mcJsBvCgGq+aS/7UPYHFb6ypfBD9fKEx/8CgYEA3GO/
    Mxn07wzkMpCGIsyavoV5ElxKsrM7DP2kLLxKil85K+AwkDEtb5Eeda/goRJ/+FlJ
    E4y/fxCW77/bmcuWEtfbmbkqVYtKZxOlbMWVulTwcQ4hNq1Z1kQZ5qW+Vc8VykVl
    efWXPlktyuy3oGAC9JqpA0+ho+RbXhWFUpqiYFUCgYEAywG61w70LqJ3JeCUsqOQ
    Qakbf6VJIW5hyLXPeyPT89qfRir9/q48gZDVYy5tTlGgRxxYrjy7+AS4SzAkNn88
    wOhXUgTZr8G3FMMudo5m2ssGY5OeLcUJcxnYMBrT51B4TzvH322FMm7n+Ji/809G
    HJUR4zuzeeXnQ+AFAQRhsZ8CgYBJ8fnEBpCE6JlkUdN/t5CwHg56V5cEkFheynec
    PuzvsnV3QDhrGOT6ywEiUYmX4aIoTKTVN2NFGebauE/RMVrAJcbbtCH9I8gp/5CA
    h2buZvNpq2j/dHhxCNZ76d6L4fiYrmIW4o0FcVyI+pW97JjxQzc0EjLUz5jMX4Il
    LhcPJQKBgQChwNruOOGfuaAlwec0ekm8s4CBcymDoBmU/6615UJ+k/fk7ewFR0jm
    ZAbcHbHofw/aSEKiI57s7o8a+bdtaF1Y7wfVax+5Hn1LpY2XWB0KTeU3PZi6APhw
    jsMtGAniWOeZY/BqriQK8EZQWGLT2P8tey0fY4f6bSrXYm0XxMNmvw==
    -----END RSA PRIVATE KEY-----"

    # Gestion de la sécurité
    class Guardian

    end

    # managing fraud
    class Faud

    end

    class Client

        # VERIFIE SI LE CLIENT A UNE VERSION COMPATIBLE POUR ECHANGER AVEC L'API
        # @params [Integer] version
        def is_client_valid?(ver)
            @version = version
            if @version >= $version
                return true
            else
                return false
            end
        end
    end

    class Security

        def self.pub
            rsa_private = OpenSSL::PKey::RSA.generate 2048

            puts rsa_public = rsa_private.public_key
        end
    end
end