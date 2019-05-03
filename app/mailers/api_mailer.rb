class ApiMailer < ApplicationMailer
  default from: "noreply@payquick-cm.com"

  def notifyAdmin

    mail(to: 'mvondoyannick@gmail.com', subject: 'Sujet de test')

  end

  #Echec de la creation du compte PAYQUICK
  # @param [Object] message
  # @param [Object] phone
  # @param [Object] date
  # @param [Object] errors
  def signupFail(message, phone, date, errors)
    @message  = message
    @phone    = phone
    @date     = date
    @errors   = errors

    mail(to: 'mvondoyannick@gmail.com', subject: 'Erreur creation compte PAYQUICK')
  end

  #Echec de la procedure de retrait
  def checkRetraitFail

  end


  #mailler generique pour toutes actions
  # @param [Object] message
  # @param [Object] phone
  # @param [Object] date
  # @param [Object] errors
  def notify(message, phone, date, errors)
    @message    = message
    @phone      = phone
    @date       = date
    @errors     = errors
    #@class_name = class_name
    #@method     = method || nil

    mail(to: 'apimail@payquick-cm.com', subject: 'Erreur creation compte PAYQUICK')
  end

end
