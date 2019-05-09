class AgentcrtlController < ApplicationController
  before_action :authenticate_agent!, except: [:signin, :attemp_signin]
  require  'rqrcode'
  def index
    parametres = {
        id: 007,
        context: :plateforme,
        phone: "ec802056cb6a84dbbfe0812ff0055dcab3a92df4",
        montant: nil,
        lat: nil,
        lon: nil,
        depart: nil,
        arrive: nil
    }.to_s
    
    qrcode = RQRCode::QRCode.new(Base64.encode64(parametres))
    @png = qrcode.as_png(
        resize_gte_to: false,
        resize_exactly_to: false,
        fill: 'white',
        color: 'black',
        size: 360,
        border_modules: 4,
        module_px_size: 6,
        file: Rails.root.join("tmp/#{SecureRandom.hex(3).parameterize}.png")
    )
    @agent = Agent.all
  end

  #login partenaire
  def signin
    render layout: 'client/application'

  end

  #Intention de connexion d'un partenaire
  def attemp_signin
    login     = params[:email]
    password  = params[:password]

    #on recherche si les valeurs sont bien presentes
    if login.present? && password.present?
      @agent = Agent.find_by_email(login)
      if @agent.blank?
        respond_to do |format|
          format.json {}
          format.html {redirect_to :signin, notice: "Utilisateur inconnu"}
        end
      else
        if @agent.valid_password?(password)
          respond_to do |format|
            format.json {}
            format.html {redirect_to agentcrtl_customer_path, notice: "Identifier en tant que #{@agent.email}"}
          end
        end
      end
    else
      respond_to do |format|
        format.html {redirect_to agentcrtl_signin_path, notice: "Aucun champ ne peu etre vide"}
        format.json {}
      end
    end
  end

  def new
    @agent = Agent.new
    puts "========= #{@agent}"
  end

  #generate QR code and save from database on table
  def generateQRCode
    id = params[:id]

    #on recherche l'enregistrement correspondant
    query = Qrmodel.find(id)
    query_string = query.to_s

    #on commence le processus de rendu du qrcode
    qrcode = RQRCode::QRCode.new(query_string)
    qrmodel.qrcode.attach(
      qrcode.as_png(
        resize_gte_to: false,
        resize_exactly_to: false,
        fill: 'white',
        color: 'black',
        size: 360,
        border_modules: 4,
        module_px_size: 6,
        file: Rails.root.join("tmp/#{SecureRandom.hex(2).parameterize}.png")
      )
    )

  end

  def new_qrcode
    @qrcode = Qrmodel.new
    service = params[:service]
     #on recherche le service en question
     query = Service.find(service)
    if !query.blank?
      @data = query
    end
  end


  #creation d'un qrcode
  def create_qrcode
    @qrcode = Qrmodel.new(qrcode_params)
    respond_to do |format|
      if @qrcode.save
        format.html {}
        format.json {}
      else
        format.html {}
        format.json {}
      end
    end
  end

  def edit
  end

  def delete
  end

  #permet de generer le QRcode
  def create_qrcode

  end

  #permet de generer le qrcode et de recuperer le chemin
  def intend_qrcode
    data = params[:customer_token]
    customer = Customer.find_by_authentication_token(data)

    #on imprime le qrcode
    customer.print_qrcode

    #on recupere le chemin du qrcode
    @path = customer.qrcode_path
    rescue => e
      render json:{
        message: "Impossible de trouver cet utilisateur : #{e}"
      }
  end

  #permet de retourner le journal des activités d'un customer
  def customer_activity
    data = params[:customer_id]
    customer = Customer.find_by_authentication_token(data)
  rescue => e
    render json: {
      message: "Une erreur est survenue. Utilisateur inconnu"
    }
  end

  #affiche les customer sur la plateforme
  def customer
    @customer = Customer.order(name: :asc)
  end

  #ajout de nouveau client sur la plateforme
  def new_customer
  end

  #intention de creation d'un nouveau customer
  def intent_new_customer
    name                    = params[:name]
    second_name             = params[:second_name]
    cni                     = params[:cni]
    cni_file                = params[:cni_file]
    phone                   = params[:phone]
    phone_confirm           = params[:phone_confirm]
    amount                  = params[:amount]
    password_operateur      = params[:password] 
    sexe                    = params[:sexe]

    #procedure de verification
    if current_agent.valid_password?(password_operateur)
      if phone != phone_confirm
        render json: {
          message:    "numero de telephone differents"
        }
      else
        #enregistrement
        query = Client::create_user(name, second_name, phone, cni, password, "Not Set")
        if query.save
          render json: {
            status:     :succes,
            messsage:   "Enregistré avec succès"
          }
        else
          rendes json: {
            status:     :failed,
            message:    "Echec d'enregistrement : #{query.errors.full_message}"
          }
        end
      end
    else
      render json: {
        message: "Impossible de d'authentifier l'operateur de saisie"
      }
    end
  end

  #crediter un compte client
  def credit_customer
    #@customer = Customer.order(name: :asc)
  end

  #pour le journal d'activité de la plateforme
  def journal
    @journal = Transaction.order(created_at: :desc)
  end

  #intention de credit du compte client
  def intent_credit_customer
    phone         = params[:phone]
    phone_confirm = params[:phone_confirm]
    amount        = params[:amount]
    password      = params[:password] 

    #procedure de verification
    if current_agent.valid_password?(password)
      if phone != phone_confirm
        render json: {
          message: "numero de telephone differents"
        }
      else
        #recherche du client sur la plateforme
        customer = Customer.find_by_phone(phone)
        if customer.blank?
          render json: {
            message: "Erreur ! #{phone} est inconnu de notre plateforme"
          }
        else
          query = Client::credit_account(phone, amount)
          render json: {
            message: query
          }
        end
      end
    else
      render json: {
        message: "Impossible de d'authentifier l'operateur de saisie"
      }
    end
  end

  #debiter un compte client
  def debit_customer_account
  end

  #permet d'activer le compte d'un utilisateur
  def activate_customer_account
    phone = params[:phone]
    if phone.present?
      query = Customer.find_by_phone(phone)
      if query.blank?
        respond_to do |format|
          format.html {redirect_to agentcrtl_activate_customer_account_path, notice: "Echec" }
        end
      else
        respond_to do |format|
          format.html {redirect_to agentcrtl_search_phone_path(token: query.authentication_token) }
        end
      end
    end
  end

  #resultat de la recherche du numero de telephone du compte
  def search_phone

  end

  #Permet de verifier si l'utilisateur est finalisé ou pas
  def is_complete?(phone)
    @phone = phone

  end

  #Permet d'activer un client
  def activate_customer
    token = params[:token]



    #on recherche le gar en question
    @customer = Customer.find_by_authentication_token(token)
    if customer.blank?

    else
      #on mets a jour les informations

    end

  end

  #intent activate customer
  def activate_customer_intent
    #donnée a traitées en get
    cni_file    = params[:cni_file]
    formulaire  = params[:formulaire]

    @customer.cni_file.attach(cni_file)
    @customer.formulaire.attach(formulaire)
    redirect_to root_path
  end

  def search
    phone     = params[:phone]
      if phone.present?
        @customer = Customer.find_by_phone(phone)
        if @customer.blank?
          respond_to do |format|
            format.html {}
          end
        else
          #on verifie si ce customer n'est pas deja bloqué
          # is_lock = Client::isLock?(@customer.authentication_token)
          # if is_lock[0] == true
          #   #le compte est effectivement utilisé
          #   respond_to do |format|
          #     format.html {redirect_to customer_s_response_path(status: 'visible', flag: false, phone: @customer.phone, message: "Cet utilisateur est deja bloqué, impossible de le bloquer de nouveau")}
          #   end
          # else
            #le compte n'esy actuellement pas bloqué
            respond_to do |format|
              format.html {redirect_to customer_s_response_path(status: 'visible',flag: true, name: @customer.name, second_name: @customer.second_name, phone: @customer.phone, sexe: @customer.sexe, token: @customer.authentication_token, cni: @customer.cni)}
            end
          #end
        end
      end
  end

  #resultat de la recherche lorsque l'on veut bloquer
  def result

  end

  #resultat de la recherche lorsque l'on veut debloquer
  def result_unlock

  end


  #Bloquer un compte ayants=signaler des problemes
  def lock_customer_account

    phone = params[:phone]

    if phone.present?
      #on recherche si cet utilisateur est dans le systeme
      @customer = Customer.find_by_phone(phone)
      if @customer.blank?
        respond_to do |format|
          format.html {redirect_to agentcrtl_lock_customer_account_path(search: 'Failed')}
        end
      else
        #on passe a la page suivante
        redirect_to customer_validate_lock_path(phone: @phone, s: "exist", action: "lock")
      end
    else
      respond_to do |format|
        format.html {}
      end
    end

  end

  #Permet de valider le blocage du customer
  def validate_lock_customer_account

  end


  #debolquer une compte d'un utilisateur precedement bloqué
  def unlock_customer_account
    
  end

  #intention de retirer le credit dans le compte client
  def intent_debit_customer
    phone         = params[:phone]
    phone_confirm = params[:phone_confirm]
    amount        = params[:amount]
    password      = params[:password]

    current_agent = Customer.find_by_phone(phone)
    if current_agent.blank?
      respond_to do |format|
        format.html {}
      end
    else
      #procedure de verification
      if current_agent.valid_password?(password)
        if phone != phone_confirm
          render json: {
              message: "numero de telephone differents"
          }
        else
          #recherche du client sur la plateforme
          customer = Customer.find_by_phone(phone)
          if customer.blank?
            render json: {
                message: "Erreur ! #{phone} est inconnu de notre plateforme"
            }
          else
            query = Client::init_retrait(phone, amount)
            render json: {
                message: query
            }
          end
        end
      else
        render json: {
            message: "Impossible de d'authentifier l'operateur de saisie"
        }
      end
    end
  end


  private
  def qrcode_params
    params.permit(:context, :montant, :lat, :lon, :depart, :arrive)
  end
end
