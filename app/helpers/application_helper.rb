module ApplicationHelper
  def notebook_page_path(pagination, page)
    query = params.permit(:category, :kind).to_h.merge(page: page, per_page: pagination.per_page)
    "#{request.path}?#{query.to_query}"
  end
end
