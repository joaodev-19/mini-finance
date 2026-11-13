module ApplicationHelper
  def notebook_page_path(pagination, page)
    query = notebook_context_params.merge(page: page, per_page: pagination.per_page)
    "#{request.path}?#{query.to_query}"
  end

  def notebook_context_params
    keys = controller_name == "entries" ? %i[search category kind per_page page] : %i[per_page page]
    params.permit(*keys).to_h
  end
end
