class CategorieServicesController < ApplicationController
  before_action :set_categorie_service, only: [:show, :edit, :update, :destroy]

  # GET /categorie_services
  # GET /categorie_services.json
  def index
    @categorie_services = CategorieService.all
  end

  # GET /categorie_services/1
  # GET /categorie_services/1.json
  def show
  end

  # GET /categorie_services/new
  def new
    @categorie_service = CategorieService.new
  end

  # GET /categorie_services/1/edit
  def edit
  end

  # POST /categorie_services
  # POST /categorie_services.json
  def create
    @categorie_service = CategorieService.new(categorie_service_params)

    respond_to do |format|
      if @categorie_service.save
        format.html { redirect_to @categorie_service, notice: 'Categorie service was successfully created.' }
        format.json { render :show, status: :created, location: @categorie_service }
      else
        format.html { render :new }
        format.json { render json: @categorie_service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categorie_services/1
  # PATCH/PUT /categorie_services/1.json
  def update
    respond_to do |format|
      if @categorie_service.update(categorie_service_params)
        format.html { redirect_to @categorie_service, notice: 'Categorie service was successfully updated.' }
        format.json { render :show, status: :ok, location: @categorie_service }
      else
        format.html { render :edit }
        format.json { render json: @categorie_service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categorie_services/1
  # DELETE /categorie_services/1.json
  def destroy
    @categorie_service.destroy
    respond_to do |format|
      format.html { redirect_to categorie_services_url, notice: 'Categorie service was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_categorie_service
      @categorie_service = CategorieService.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def categorie_service_params
      params.require(:categorie_service).permit(:name, :detail)
    end
end
