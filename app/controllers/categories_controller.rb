class CategoriesController < ApplicationController
  before_action :remember_entry_form, only: :index
  before_action :set_category, only: %i[ show edit update destroy ]

  # GET /categories or /categories.json
  def index
    @categories = Category.all
  end

  # GET /categories/1 or /categories/1.json
  def show
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories or /categories.json
  def create
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to categories_path, notice: "Category was successfully created." }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @category.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /categories/1 or /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: "Category was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @category.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /categories/1 or /categories/1.json
  def destroy
    if @category.destroy
      redirect_to categories_path,
        notice: "Categoria excluída com sucesso.",
        status: :see_other
    else
      redirect_to categories_path,
        alert: "Não é possível excluir uma categoria com lançamentos vinculados.",
        status: :see_other
    end
  end

  private
    def remember_entry_form
      return unless params[:from_entry] == "1"

      session[:category_return_entry_id] = Entry.find_by(id: params[:entry_id])&.id
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def category_params
      params.expect(category: [ :name ])
    end
end
