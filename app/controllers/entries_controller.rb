class EntriesController < ApplicationController
  include NotebookPaginatable

  before_action :set_entry, only: %i[ show edit update destroy ]
  before_action :set_categories, only: %i[index new edit create update]

  # GET /entries or /entries.json
  def index
    @entries = Entry.includes(:category).order(occurred_on: :desc, id: :desc)
    @entries = @entries.filter_by_title(params[:search]) if params[:search].present?
    @entries = @entries.filter_by_category(params[:category]) if params[:category].present?
    @entries = @entries.filter_by_kind(params[:kind]) if params[:kind].present?
    @entries = paginate_notebook(@entries) if request.format.html?
  end

  # GET /entries/1 or /entries/1.json
  def show
  end

  # GET /entries/new
  def new
    @entry = Entry.new
  end

  # GET /entries/1/edit
  def edit
  end

  # POST /entries or /entries.json
  def create
    @entry = Entry.new(entry_params)

    respond_to do |format|
      if @entry.save
        format.html { redirect_to @entry, notice: "Entry was successfully created." }
        format.json { render :show, status: :created, location: @entry }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @entry.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /entries/1 or /entries/1.json
  def update
    respond_to do |format|
      if @entry.update(entry_params)
        format.html { redirect_to @entry, notice: "Entry was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @entry }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @entry.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /entries/1 or /entries/1.json
  def destroy
    @entry.destroy!

    respond_to do |format|
      format.html { redirect_to entries_path, notice: "Entry was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_entry
      @entry = Entry.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def entry_params
      params.expect(entry: [ :title, :amount, :occurred_on, :description, :category_id, :kind ])
    end

    def set_categories
      @categories = Category.order(:name)
    end
end
