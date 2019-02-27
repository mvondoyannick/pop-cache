class HomeController < ApplicationController
  before_action :authenticate_agent!, only: [:retrait, :index]
  layout 'lte/application'
  def index
  
  end

  def retrait
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
    query = Client::create_user(params[:nom],params[:prenom],params[:phone], params[:cni],params[:password])
    render json: {
      message: 'succes',
      description: 'Nouvel utilisateur creer',
      code: query
    }
  end

  def login
  end

  def signup
  end
end
