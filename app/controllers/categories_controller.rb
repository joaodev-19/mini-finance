class CategoriesController < ApplicationController
  include NotebookPaginatable

  before_action :remember_entry_form, only: :index
  before_action :set_category, only: %i[ show edit update destroy ]


  # GET /categories or /categories.json
  def index
    @categories = Current.user.categories.order(:name, :id)
    @categories = paginate_notebook(@categories) if request.format.html?
  end

  # GET /categories/1 or /categories/1.json
  def show
  end

  # GET /categories/new
  def new
    @category = Current.user.categories.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories or /categories.json
  def create
    @category = Current.user.categories.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to categories_path, notice: "Categoria criada com sucesso." }
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
        format.html { redirect_to @category, notice: "Categoria atualizada com sucesso.", status: :see_other }
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
      redirect_to categories_path(params.permit(:per_page, :page).to_h),
        notice: "Categoria excluída com sucesso.",
        status: :see_other
    else
      redirect_to categories_path(params.permit(:per_page, :page).to_h),
        alert: "Não é possível excluir uma categoria com lançamentos vinculados.",
        status: :see_other
    end
  end

  private
    def remember_entry_form
      return unless params[:from_entry] == "1"

      session[:category_return_entry_id] = Current.user.entries.find_by(id: params[:entry_id])&.id
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Current.user.categories.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def category_params
      params.expect(category: [ :name ])
    end
end
