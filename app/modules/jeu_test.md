# Setting Up Fraud Management Filters

## RESTRICTION DE MOT DE PASSE FACILE

Cette mise à jour fournir le support de la fraude sur le mot de passe de l'utilisateur en iterdissant l'utilisation des mot de passe simple tel que
* 123456
* 000000
* 111111
* abcdef
* 654321

si in tel mot de passe est fournis (ayant des contraites de refus), la procedure de creation de compte n'ira pas jusqu'a la fin et sera purement et simplement rejetée.

    ```ruby

    Client.signup("moi", "moi", 666666666, "KJLKJDLKJDLKDJLKDJ", "000000", "masculin", 2, "Aucun", "41.202.219.79")
    
    BLACK_PASSWORD = %w(111111 123456 000000 654321 222222 333333 444444 555555 666666 777777 888888 999999 )
    if @password.in?(BLACK_PASSWORD)
      return false, "Ce mot de passe est interdit"
    else
      return true, "valid password"
    end

    ```

    