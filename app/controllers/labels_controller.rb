class LabelsController < ApplicationController
  before_action :set_label, only: [:show, :edit, :update, :destroy, :faces, :faces_list, :inferences]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  # GET /labels
  # GET /labels.json
  def index
    respond_to do |format|
      format.html do
        if (q = params[:q])
          where = [
            'name LIKE ? OR description LIKE ? OR twitter LIKE ?',
            *["%#{q.gsub(/([_%])/, '\\\\\1')}%"] * 3
          ]
        end
        @labels = Label
          .order(params.fetch(:order, :description))
          .where('id >= ?', 0)
          .where(where)
          .page(params[:page])
          .per(100)
        @counts = Face
          .select(:label_id)
          .group(:label_id)
          .where(label_id: @labels.map(&:id))
          .count
      end
      format.json do
        @labels = Label
          .where.not(index_number: nil)
          .where('id >= ?', 0)
          .order(:index_number)
      end
    end
  end

  def all
    @labels = Label.where('id >= ?', 0).all
    respond_to do |format|
      format.json
    end
  end

  # GET /labels/1
  # GET /labels/1.json
  def show
  end

  # GET /labels/new
  def new
    @label = Label.new
  end

  # GET /labels/1/edit
  def edit
  end

  # POST /labels
  def create
    @label = Label.new(label_params)

    respond_to do |format|
      if @label.save
        format.html { redirect_to label_path(@label), notice: 'Label was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /labels/1
  def update
    respond_to do |format|
      if @label.update(label_params)
        format.html { redirect_to label_path(@label), notice: 'Label was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /labels/1
  def destroy
    @label.destroy
    respond_to do |format|
      format.html { redirect_to labels_url, notice: 'Label was successfully destroyed.' }
    end
  end

  # GET /labels/1/faces
  def faces
    @faces = Face
      .joins(:photo)
      .where(label_id: params[:id])
      .order('photos.posted_at DESC')
      .order('id DESC')
      .page(params[:page])
      .per(100)
    render 'faces/index'
  end

  # GET /labels/1/faces_list
  def faces_list
    @faces = Face
      .joins(:photo)
      .where(label_id: params[:id])
      .order('photos.posted_at DESC')
      .page(params[:page])
      .per(20)
    render 'faces/list'
  end

  # GET /labels/1/inferences
  def inferences
    @inferences = @label.inferences
      .includes(face: :photo)
      .order(score: :desc)
      .page(params[:page])
      .per(5)
    render 'inferences/index'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_label
    @label = Label.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def label_params
    params.require(:label).permit(:name, :index_number, :description, :url, :twitter, :tags, :status)
  end
end
