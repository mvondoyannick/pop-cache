class Api::V1::CustomerController < ApplicationController
  #controller entierement dedier à la gestion des clients en ligne
  def signin
    @email      = params[:phone]
    @password   = params[:password]

    #begin transaction
    query = CustomerDesktop::Client.signin(@email, @password)
    puts "response : #{query}"
    render json: {
        status:   query[0],
        message:  query[1]
    }
  end


  def validate_signin
    @phone = params[:phone]
    @code = params[:code]

    query = CustomerDesktop::Client.confirm_signin(@phone, @code)
    puts query
    render json: {
      status:   query[0],
      message:  query[1]
    }
  end


  def signup

  end

  def history
    @token      = params[:token]

    #process to research
    customer = Customer.find_by_authentication_token(@token)
    if customer.blank?
      render json: {
          status: false,
          message: 'customer not found'
      }
    else
      #on recherche toute l'historique
      query = CustomerDesktop::Client.history(customer.authentication_token)
      if query.blank?
        render json: {
            status:   query[0],
            message:  query[1]
        }
      else
        render json: {
            status:   query[0],
            message:  query[1]
        }
      end
    end

  end
end