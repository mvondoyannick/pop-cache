class AgentcrtlController < ApplicationController
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


  private
  def qrcode_params
    params.permit(:context, :montant, :lat, :lon, :depart, :arrive)
  end
end
