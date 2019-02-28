class HomeController < ApplicationController
  before_action :authenticate_agent!, only: [:retrait, :index]
  layout 'render/yield'
  def index
  
  end

  def retrait
    phone = params[:phone]
    amount = params[:amount]

    #on verifie que le client est bien en
    query = Client::init_retrait(phone, amount)
    puts query
  end

  #execution de la procedure de retrait effective
  def retrait_intend
    # puts params[:phone]
    # query = Client::init_retrait(params[:phone], params[:amount])
    # render json: {
    #   message: 'succes',
    #   description: 'retrait initialisé',
    #   code: query
    # }
  end

  def public
    @transaction = Transaction.all
  end

  def private
  end

  "compte pour le particulier"
  def particulier
    @particulier = Customer.order(created_at: :desc)
  end

  def compte

  end

  def create
    #query = Client::create_user(params[:nom],params[:prenom],params[:phone], params[:cni],params[:password])
    #render json: {
    #  message: 'succes',
    #  description: 'Nouvel utilisateur creer',
    #  code: query
    #}
  end

  def login
  end

  #crediter le compte d'un utilisateur de la plateforme
  def credit
    phone = params[:phone]
    amount = params[:amount]

    #demarrage de la procedure
    query = Client::credit_account(phone, amount)
    puts query
  end

  def signup
  end
end
