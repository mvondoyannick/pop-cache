class TypesController < ApplicationController
  before_action :set_type, only: [:show, :edit, :update, :destroy]

  # GET /types
  # GET /types.json
  def index
    require 'open-uri'

    @types = Type.all
    respond_to do |format|
      format.html
      format.pdf do
        pdf = Prawn::Document.new
        y_position = pdf.cursor
        pdf.image "#{Rails.root}/fc.png", scale: 0.45
        #pdf.text "Hello to prawn"
        pdf.move_down 50
        pdf.image "#{Rails.root}/test.svg.png", scale: 0.35, position: 427, vposition: 15
        pdf.move_down 20
        pdf.encrypt_document(user_password: "paymequick", owner_password: :random, :permission => {
            :print_document => false,
            :modify_documents => false,
            :copy_contents => false,
            :modify_annotations => false
        })
        send_data pdf.render, type: "application/pdf", disposition: "inline"
      end
    end
  end

  # GET /types/1
  # GET /types/1.json
  def show
  end

  # GET /types/new
  def new
    @type = Type.new
  end

  # GET /types/1/edit
  def edit
  end

  # POST /types
  # POST /types.json
  def create
    @type = Type.new(type_params)

    respond_to do |format|
      if @type.save
        format.html { redirect_to @type, notice: 'Type was successfully created.' }
        format.json { render :show, status: :created, location: @type }
      else
        format.html { render :new }
        format.json { render json: @type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /types/1
  # PATCH/PUT /types/1.json
  def update
    respond_to do |format|
      if @type.update(type_params)
        format.html { redirect_to @type, notice: 'Type was successfully updated.' }
        format.json { render :show, status: :ok, location: @type }
      else
        format.html { render :edit }
        format.json { render json: @type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /types/1
  # DELETE /types/1.json
  def destroy
    @type.destroy
    respond_to do |format|
      format.html { redirect_to types_url, notice: 'Type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_type
      @type = Type.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def type_params
      params.require(:type).permit(:name, :description)
    end
end
