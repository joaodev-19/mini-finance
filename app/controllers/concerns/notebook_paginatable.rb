module NotebookPaginatable
  private

    def paginate_notebook(records)
      @pagination = NotebookPagination.new(total_count: records.count, page: params[:page], per_page: params[:per_page])
      records.limit(@pagination.per_page).offset(@pagination.offset)
    end
end
